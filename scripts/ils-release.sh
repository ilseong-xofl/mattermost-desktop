#!/usr/bin/env bash

# exit when any command fails
set -e

function print_error {
    echo -e "[ERROR  ] $*"
}
function print_warning {
    echo -e "[WARNING] $*"
}
function print_info {
    echo -e "[INFO   ] $*"
}

function tag {
    # not forcing tags, this might fail on purpose if tags are already created
    # as we don't want to overwrite automatically.
    # if this happens, you should check that versions are ok and see if there are
    # any tags locally or upstream that might conflict.
    git tag -a "v${1}" -f -m "Desktop Version ${2}"
}

function tag_push {
    git push --follow-tags ${git_origin} ${branch_name}:${branch_name}
}

function write_package_version {
    temp_file="$(mktemp -t package.json.XXXX)"
    jq ".version = \"${1}\"" ./package.json > "${temp_file}" && mv "${temp_file}" ./package.json
    temp_file="$(mktemp -t package-lock.json.XXXX)"
    jq ".version = \"${1}\"" ./package-lock.json > "${temp_file}" && mv "${temp_file}" ./package-lock.json

    git add ./package.json ./package-lock.json
    git commit -qm "Bump to version ${1}"
}

# mattermost repo might not be the origin one, we don't want to enforce that.
org="github.com:mattermost|https://github.com/mattermost"
git_origin="$(git remote -v | grep -E ${org} | grep push | awk '{print $1}')"
if [[ -z "${git_origin}" ]]; then
    print_warning "Can't find a mattermost remote, defaulting to origin"
    git_origin="origin"
fi

# get original git branch
branch_name="$(git symbolic-ref -q HEAD)"
branch_name="${branch_name##refs/heads/}"
branch_name="${branch_name:-HEAD}"

# Path: scripts/ils-release.sh
create_tag()
{
  while true; do
    read -p "생성할 tag 버전을 입력해주세요 [ ex) 0.0.1 ]: " VERSION

    # 버전 타입이 올바른지 체크
    echo $VERSION | egrep -q "^[0-9]+\.[0-9]+\.[0-9]+$"

    if [ $? == 0 ]; then
      # 올바른 버전 타입인 경우
      # package.json 에 버전을 입력
      write_package_version "${VERSION}"
      print_info "Package.json Version Update 완료 ( ${VERSION} )"

      # tag 생성
      tag "${VERSION}" "Released on $(date -u)"
      tag_push

      # tag 생성 후 push 문구
      print_info "$ git push --follow-tags origin ${branch_name}:${branch_name}"

      print_info "Git tag push 완료 ( ${VERSION} )"
      break
    else
      echo "잘못된 버전 타입입니다."
      echo "버전 타입을 확인해주세요. ex) 0.0.1 "
    fi
  done
}

create_tag
