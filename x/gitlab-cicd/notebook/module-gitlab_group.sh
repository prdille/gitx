> COMMUNITY.GENERAL.GITLAB_GROUP    (/usr/local/lib/python3.9/site-packages/ansible_collections/community/general/plugins/modules/gitlab_group.py)

        When the group does not exist in GitLab, it will be created.
        When the group does exist and state=absent, the group will be
        deleted.

OPTIONS (= is mandatory):

- api_password
        The password to use for authentication against the API
        [Default: (null)]
        type: str

- api_token
        GitLab token for logging in.
        [Default: (null)]
        type: str

- api_url
        The resolvable endpoint for the API
        [Default: (null)]
        type: str

- api_username
        The username to use for authentication against the API
        [Default: (null)]
        type: str

- description
        A description for the group.
        [Default: (null)]
        type: str

= name
        Name of the group you want to create.

        type: str

- parent
        Allow to create subgroups
        Id or Full path of parent group in the form of group/name
        [Default: (null)]
        type: str

- path
        The path of the group you want to create, this will be
        api_url/group_path
        If not supplied, the group_name will be used.
        [Default: (null)]
        type: str

- state
        create or delete group.
        Possible values are present and absent.
        (Choices: present, absent)[Default: present]
        type: str

- validate_certs
        Whether or not to validate SSL certs when supplying a https
        endpoint.
        [Default: True]
        type: bool

- visibility
        Default visibility of the group
        (Choices: private, internal, public)[Default: private]
        type: str


REQUIREMENTS:  python >= 2.7, python-gitlab python module

AUTHOR: Werner Dijkerman (@dj-wasabi), Guillaume Martinez (@Lunik)

EXAMPLES:

- name: "Delete GitLab Group"
  community.general.gitlab_group:
    api_url: https://gitlab.example.com/
    api_token: "{{ access_token }}"
    validate_certs: False
    name: my_first_group
    state: absent

- name: "Create GitLab Group"
  community.general.gitlab_group:
    api_url: https://gitlab.example.com/
    validate_certs: True
    api_username: dj-wasabi
    api_password: "MySecretPassword"
    name: my_first_group
    path: my_first_group
    state: present

# The group will by created at https://gitlab.dj-wasabi.local/super_parent/parent/my_first_group
- name: "Create GitLab SubGroup"
  community.general.gitlab_group:
    api_url: https://gitlab.example.com/
    validate_certs: True
    api_username: dj-wasabi
    api_password: "MySecretPassword"
    name: my_first_group
    path: my_first_group
    state: present
    parent: "super_parent/parent"


RETURN VALUES:
- error
        the error message returned by the GitLab API

        returned: failed
        sample: 400: path is already in use
        type: str

- group
        API object

        returned: always
        type: dict

- msg
        Success or failure message

        returned: always
        sample: Success
        type: str

- result
        json parsed response from the server

        returned: always
        type: dict
