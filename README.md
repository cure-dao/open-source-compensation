# Aragon Agent

https://hack.aragon.org/docs/guides-use-agent

I needed to run as root with Node version 10.24.1

# open-source-compensation

Retroactive public goods compensation for open-source developers contributing to CureDAO stack

Libraries we use are listed in the composer.json and package.json files of all cure-dao repositories.

```
create table open_source_repositories
(
    id                     int unsigned    null,
    curedao_repository_id  bigint unsigned null,
    client_id              tinytext        null,
    started_using_at             timestamp       null   'When the library started being used by the CureDAO project',
    stopped_using_at             timestamp       null   'When the library was removed from CureDAO project',
    created_at             timestamp       null,
    deleted_at             timestamp       null,
    updated_at             timestamp       null,
    user_id                bigint unsigned null,
    github_repository_id   int             null,
    node_id                tinytext        null,
    name                   tinytext        null,
    full_name              tinytext        null,
    private                tinyint         null,
    owner                  longtext        null,
    html_url               tinytext        null,
    description            tinytext        null,
    fork                   tinyint         null,
    url                    tinytext        null,
    forks_url              tinytext        null,
    keys_url               tinytext        null,
    collaborators_url      tinytext        null,
    teams_url              tinytext        null,
    hooks_url              tinytext        null,
    issue_events_url       tinytext        null,
    events_url             tinytext        null,
    assignees_url          tinytext        null,
    branches_url           tinytext        null,
    tags_url               tinytext        null,
    blobs_url              tinytext        null,
    git_tags_url           tinytext        null,
    git_refs_url           tinytext        null,
    trees_url              tinytext        null,
    statuses_url           tinytext        null,
    languages_url          tinytext        null,
    stargazers_url         tinytext        null,
    contributors_url       tinytext        null,
    subscribers_url        tinytext        null,
    subscription_url       tinytext        null,
    commits_url            tinytext        null,
    git_commits_url        tinytext        null,
    comments_url           tinytext        null,
    issue_comment_url      tinytext        null,
    contents_url           tinytext        null,
    compare_url            tinytext        null,
    merges_url             tinytext        null,
    archive_url            tinytext        null,
    downloads_url          tinytext        null,
    issues_url             tinytext        null,
    pulls_url              tinytext        null,
    milestones_url         tinytext        null,
    notifications_url      tinytext        null,
    labels_url             tinytext        null,
    releases_url           tinytext        null,
    deployments_url        tinytext        null,
    pushed_at              tinytext        null,
    git_url                tinytext        null,
    ssh_url                tinytext        null,
    clone_url              tinytext        null,
    svn_url                tinytext        null,
    homepage               tinytext        null,
    size                   int             null,
    stargazers_count       int             null,
    watchers_count         int             null,
    language               tinytext        null,
    has_issues             tinyint         null,
    has_projects           tinyint         null,
    has_downloads          tinyint         null,
    has_wiki               tinyint         null,
    has_pages              tinyint         null,
    forks_count            int             null,
    archived               tinyint         null,
    disabled               tinyint         null,
    open_issues_count      int             null,
    allow_forking          tinyint         null,
    is_template            tinyint         null,
    topics                 text            null,
    visibility             tinytext        null,
    forks                  int             null,
    open_issues            int             null,
    watchers               int             null,
    default_branch         tinytext        null,
    permissions            longtext        null,
    temp_clone_token       tinytext        null,
    allow_squash_merge     tinyint         null,
    allow_merge_commit     tinyint         null,
    allow_rebase_merge     tinyint         null,
    allow_auto_merge       tinyint         null,
    delete_branch_on_merge tinyint         null,
    network_count          int             null,
    subscribers_count      int             null,
    score                  int             null,
    mirror_url             tinytext        null,
    license                tinytext        null
);
```

### Update `open_source_repositories` table:

1. Read the composer.json and package.json files of all cure-dao repositories
2. Fetch the data about each repo from the GitHub API: https://docs.github.com/en/rest/reference/repos
3. `INSERT IGNORE` the GitHub API response into the `open_source_repositories` table with `started_using_at` and `curedao_repository_id`

### Update `stopped_using_at` in `open_source_repositories` table for removed packages:

1. Loop through all records in `open_source_repositories` table and set `stopped_using_at` to current date if not found in package.json or composer.json

### Update `open_source_contributors` table:

1. [Fetch all commits](https://docs.github.com/en/rest/reference/commits) to each library and store each one in a `open_source_commits` table along with the `github_user_id` `github_username`, `commit_date`, `number_of_lines`, and `commit_sha`, and the `curedao_tokens_awarded` for that git commit
2. Fetch a list of all contributor emails to each library from the [GitHub API](https://docs.github.com/en/rest/reference/users) and store it in an `open_source_contributors` table in the CureDAO database with their `github_username`, `github_id`, `email`, `name`, and `last_emailed_at` field.

### Get Harmony Address from Newly Added Contributors

1. Email every contributor with a `null` `last_emailed_at` field explaining CureDAO's mission and why we're paying them
2. Explain that they will receive an ongoing percentage of all revenue from the project in proportion to their fraction of total minted CURE tokens
3. Provide instructions about how to add the Harmony ONE chain to their Metamask wallet
4. Provide a link to a GitHub login form
5. After they log in, send them to a https://notionforms.io/forms/join-curedao (or one we make) where they can enter their GitHub ID and Harmony ONE address
6. Store their Harmony address in the `open_source_contributors` table.

### Send Tokens Every X Days for New Commits

1. Fetch the commits from the `open_source_commits` table, where the `curedao_tokens_awarded` is null.
2. Fetch the `open_source_contributors` for the commits
3. Calculated total number of tokens to be awarded
4. Send tokens to their address
5. Send email asking them to click a link to confirm they received the tokens (along with link to more information about the project in case they forgot) or click a different link to report that they didn't receive them
6. If they click neither link, mark them as unresponsive in the database and don't send future tokens until we hear from them. (We don't want to waste them on dead emails or people who don't care about them.)

### Questions

1. How should the amount of CURE tokens be determined? (Number of commits? Number of lines committed? A combination?  Something else?)
2. How often should we send them to maximize immediate gratification while avoiding spamming them?  Every 14 days?

### References

- https://github.com/aragon/aragon.js
