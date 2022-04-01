---
stage: none
group: Style Guide
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
description: 'Writing styles, markup, formatting, and other standards for GitLab Documentation.'
---

# A-Z word list

To help ensure consistency in the documentation, follow this guidance.

For guidance not on this page, we defer to these style guides:

- [Microsoft Style Guide](https://docs.microsoft.com/en-us/style-guide/welcome/)
- [Google Developer Documentation Style Guide](https://developers.google.com/style)

<!-- vale off -->
<!-- markdownlint-disable -->

## @mention

Try to avoid. Say "mention" instead, and consider linking to the
[mentions topic](../../../user/project/issues/issue_data_and_actions.md#mentions).
Don't use `code formatting`.

## above

Try to avoid extra words when referring to an example or table in a documentation page, but if required, use **previously** instead.

## admin, admin area

Use **administration**, **administrator**, **administer**, or **Admin Area** instead. ([Vale](../testing.md#vale) rule: [`Admin.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/Admin.yml))

## allow, enable

Try to avoid, unless you are talking about security-related features. For example:

- Avoid: This feature allows you to create a pipeline.
- Use instead: Use this feature to create a pipeline.

This phrasing is more active and is from the user perspective, rather than the person who implemented the feature.
[View details in the Microsoft style guide](https://docs.microsoft.com/en-us/style-guide/a-z-word-list-term-collections/a/allow-allows).

## Alpha

Uppercase. For example: **The XYZ feature is in Alpha.** or **This Alpha release is ready to test.**

You might also want to link to [this section](https://about.gitlab.com/handbook/product/gitlab-the-product/#alpha-beta-ga)
in the handbook when writing about Alpha features.

## and/or

Instead of **and/or**, use or or rewrite the sentence to spell out both options.

## below

Try to avoid extra words when referring to an example or table in a documentation page, but if required, use **following** instead.

## Beta

Uppercase. For example: **The XYZ feature is in Beta.** or **This Beta release is ready to test.**

You might also want to link to [this section](https://about.gitlab.com/handbook/product/gitlab-the-product/#alpha-beta-ga)
in the handbook when writing about Beta features.

## blacklist

Do not use. Another option is **denylist**. ([Vale](../testing.md#vale) rule: [`InclusionCultural.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/InclusionCultural.yml))

## board

Use lowercase for **boards**, **issue boards**, and **epic boards**.

## checkbox

One word, **checkbox**. Do not use **check box**.

## CI/CD

Always uppercase. No need to spell out on first use.

## currently

Do not use when talking about the product or its features. The documentation describes the product as it is today. ([Vale](../testing.md#vale) rule: [`CurrentStatus.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/CurrentStatus.yml))

## Developer

When writing about the Developer role:

- Use a capital **D**.
- Do not use bold.
- Do not use the phrase, **if you are a developer** to mean someone who is assigned the Developer
  role. Instead, write it out. For example, **if you are assigned the Developer role**.
- To describe a situation where the Developer role is the minimum required:
  - Avoid: **the Developer role or higher**
  - Use instead: **at least the Developer role**

Do not use **Developer permissions**. A user who is assigned the Developer role has a set of associated permissions.

## disable

See [the Microsoft style guide](https://docs.microsoft.com/en-us/style-guide/a-z-word-list-term-collections/d/disable-disabled) for guidance.
Use **inactive** or **off** instead. ([Vale](../testing.md#vale) rule: [`InclusionAbleism.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/InclusionAbleism.yml))

## earlier

Use when talking about version numbers.

- Avoid: In GitLab 14.1 and lower.
- Use instead: In GitLab 14.1 and earlier.

## easily

Do not use. If the user doesn't find the process to be easy, we lose their trust.

## e.g.

Do not use Latin abbreviations. Use **for example**, **such as**, **for instance**, or **like** instead. ([Vale](../testing.md#vale) rule: [`LatinTerms.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/LatinTerms.yml))

## email

Do not use **e-mail** with a hyphen. When plural, use **emails** or **email messages**.

## enable

See [the Microsoft style guide](https://docs.microsoft.com/en-us/style-guide/a-z-word-list-term-collections/e/enable-enables) for guidance.
Use **active** or **on** instead. ([Vale](../testing.md#vale) rule: [`InclusionAbleism.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/InclusionAbleism.yml))

## epic

Lowercase.

## epic board

Lowercase.

## etc.

Try to avoid. Be as specific as you can. Do not use **and so on** as a replacement.

- Avoid: You can update objects, like merge requests, issues, etc.
- Use instead: You can update objects, like merge requests and issues.

## foo

Do not use in product documentation. You can use it in our API and contributor documentation, but try to use a clearer and more meaningful example instead.

## future tense

When possible, use present tense instead. For example, use `after you execute this command, GitLab displays the result` instead of `after you execute this command, GitLab will display the result`. ([Vale](../testing.md#vale) rule: [`FutureTense.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/FutureTense.yml))

## Geo

Title case.

## GitLab

Do not make possessive (GitLab's). This guidance follows [GitLab Trademark Guidelines](https://about.gitlab.com/handbook/marketing/corporate-marketing/brand-activation/trademark-guidelines/).

## GitLab.com

Refers to the GitLab instance managed by GitLab itself.

## GitLab SaaS

Refers to the product license that provides access to GitLab.com. Does not refer to the
GitLab instance managed by GitLab itself.

## GitLab Runner

Title case. This is the product you install. See also [runners](#runner-runners) and [this issue](https://gitlab.com/gitlab-org/gitlab/-/issues/233529).

## GitLab self-managed

Refers to the product license for GitLab instances managed by customers themselves.

## Guest

When writing about the Guest role:

- Use a capital **G**.
- Do not use bold.
- Do not use the phrase, **if you are a guest** to mean someone who is assigned the Guest
  role. Instead, write it out. For example, **if you are assigned the Guest role**.
- To describe a situation where the Guest role is the minimum required:
  - Avoid: **the Guest role or higher**
  - Use instead: **at least the Guest role**

Do not use **Guest permissions**. A user who is assigned the Guest role has a set of associated permissions.

## handy

Do not use. If the user doesn't find the feature or process to be handy, we lose their trust.

## high availability, HA

Do not use. Instead, direct readers to the GitLab [reference architectures](../../../administration/reference_architectures/index.md) for information about configuring GitLab for handling greater amounts of users.

## higher

Do not use when talking about version numbers.

- Avoid: In GitLab 14.1 and higher.
- Use instead: In GitLab 14.1 and later.

## I

Do not use first-person singular. Use **you**, **we**, or **us** instead. ([Vale](../testing.md#vale) rule: [`FirstPerson.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/FirstPerson.yml))

## i.e.

Do not use Latin abbreviations. Use **that is** instead. ([Vale](../testing.md#vale) rule: [`LatinTerms.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/LatinTerms.yml))

## in order to

Do not use. Use **to** instead. ([Vale](../testing.md#vale) rule: [`Wordy.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/Wordy.yml))

## issue

Lowercase.

## issue board

Lowercase.

## issue weights

Lowercase.

## job

Do not use **build** to be synonymous with **job**. A job is defined in the `.gitlab-ci.yml` file and runs as part of a pipeline.

If you want to use **CI** with the word **job**, use **CI/CD job** rather than **CI job**.

## later

Use when talking about version numbers.

- Avoid: In GitLab 14.1 and higher.
- Use instead: In GitLab 14.1 and later.

## log in, log on

Do not use. Use [sign in](#sign-in) instead. If the user interface has **Log in**, you can use it.

## lower

Do not use when talking about version numbers.

- Avoid: In GitLab 14.1 and lower.
- Use instead: In GitLab 14.1 and earlier.

## Maintainer

When writing about the Maintainer role:

- Use a capital **M**.
- Do not use bold.
- Do not use the phrase, **if you are a maintainer** to mean someone who is assigned the Maintainer
  role. Instead, write it out. For example, **if you are assigned the Maintainer role**.
- To describe a situation where the Maintainer role is the minimum required:
  - Avoid: **the Maintainer role or higher**
  - Use instead: **at least the Maintainer role**

Do not use **Maintainer permissions**. A user who is assigned the Maintainer role has a set of associated permissions.

## mankind

Do not use. Use **people** or **humanity** instead. ([Vale](../testing.md#vale) rule: [`InclusionGender.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/InclusionGender.yml))

## manpower

Do not use. Use words like **workforce** or **GitLab team members**. ([Vale](../testing.md#vale) rule: [`InclusionGender.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/InclusionGender.yml))

## master

Do not use. Options are **primary** or **main**. ([Vale](../testing.md#vale) rule: [`InclusionCultural.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/InclusionCultural.yml))

## may, might

**Might** means something has the probability of occurring. **May** gives permission to do something. Consider **can** instead of **may**.

## me, myself, mine

Do not use first-person singular. Use **you**, **we**, or **us** instead. ([Vale](../testing.md#vale) rule: [`FirstPerson.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/FirstPerson.yml))

## merge requests

Lowercase. If you use **MR** as the acronym, spell it out on first use.

## milestones

Lowercase.

## need to, should

Try to avoid. If something is required, use **must**.

- Avoid: You need to set the variable.
- Use instead: You must set the variable. Or: Set the variable.

**Should** is acceptable for recommended actions or items, or in cases where an event may not
happen. For example:

- Although you can configure the installation manually, you should use the express configuration to
  avoid complications.
- You should see a success message in the console. Contact support if an error message appears
  instead.

## note that

Do not use.

- Avoid: Note that you can change the settings.
- Use instead: You can change the settings.

## Owner

When writing about the Owner role:

- Use a capital **O**.
- Do not use bold.
- Do not use the phrase, **if you are an owner** to mean someone who is assigned the Owner
  role. Instead, write it out. For example, **if you are assigned the Owner role**.

Do not use **Owner permissions**. A user who is assigned the Owner role has a set of associated permissions.

## permissions

Do not use roles and permissions interchangeably. Each user is assigned a role. Each role includes a set of permissions.

## please

Do not use. For details, see the [Microsoft style guide](https://docs.microsoft.com/en-us/style-guide/a-z-word-list-term-collections/p/please).

## profanity

Do not use. Doing so may negatively affect other users and contributors, which is contrary to the GitLab value of [Diversity, Inclusion, and Belonging](https://about.gitlab.com/handbook/values/#diversity-inclusion).

## Reporter

When writing about the Reporter role:

- Use a capital **R**.
- Do not use bold.
- Do not use the phrase, **if you are a reporter** to mean someone who is assigned the Reporter
  role. Instead, write it out. For example, **if you are assigned the Reporter role**.
- To describe a situation where the Reporter role is the minimum required:
  - Avoid: **the Reporter role or higher**
  - Use instead: **at least the Reporter role**

Do not use **Reporter permissions**. A user who is assigned the Reporter role has a set of associated permissions.

## Repository Mirroring

Title case.

## roles

Do not use roles and permissions interchangeably. Each user is assigned a role. Each role includes a set of permissions.

## runner, runners

Lowercase. These are the agents that run CI/CD jobs. See also [GitLab Runner](#gitlab-runner) and [this issue](https://gitlab.com/gitlab-org/gitlab/-/issues/233529).

## sanity check

Do not use. Use **check for completeness** instead. ([Vale](../testing.md#vale) rule: [`InclusionAbleism.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/InclusionAbleism.yml))

## scalability

Do not use when talking about increasing GitLab performance for additional users. The words scale or scaling are sometimes acceptable, but references to increasing GitLab performance for additional users should direct readers to the GitLab [reference architectures](../../../administration/reference_architectures/index.md) page.

## setup, set up

Use **setup** as a noun, and **set up** as a verb. For example:

- Your remote office setup is amazing.
- To set up your remote office correctly, consider the ergonomics of your work area.

## sign in

Use instead of **sign on** or **log on** or **log in**. If the user interface has different words, use those.

You can use **single sign-on**.

## simply, simple

Do not use. If the user doesn't find the process to be simple, we lose their trust.

## slashes

Instead of **and/or**, use **or** or re-write the sentence. This rule also applies to other slashes, like **follow/unfollow**. Some exceptions (like **CI/CD**) are allowed.

## slave

Do not use. Another option is **secondary**. ([Vale](../testing.md#vale) rule: [`InclusionCultural.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/InclusionCultural.yml))

## subgroup

Use instead of **sub-group**.

## that

Do not use when describing a noun. For example:

- Avoid: The file **that** you save...
- Use instead: The file you save...

See also [this, these, that, those](#this-these-that-those).

## terminal

Lowercase. For example:

- Open a terminal.
- From a terminal, run the `docker login` command.

## there is, there are

Try to avoid. These phrases hide the subject.

- Avoid: There are holes in the bucket.
- Use instead: The bucket has holes.

## they

Avoid the use of gender-specific pronouns, unless referring to a specific person.
Use a singular [they](https://developers.google.com/style/pronouns#gender-neutral-pronouns) as
a gender-neutral pronoun.

## this, these, that, those

Always follow these words with a noun. For example:

- Avoid: **This** improves performance.
- Use instead: **This setting** improves performance.

- Avoid: **These** are the best.
- Use instead: **These pants** are the best.

- Avoid: **That** is the one you are looking for.
- Use instead: **That Jedi** is the one you are looking for.

- Avoid: **Those** need to be configured.
- Use instead: **Those settings** need to be configured. (Or even better, **Configure those settings.**)

## to-do item

Use lowercase. ([Vale](../testing.md#vale) rule: [`ToDo.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/ToDo.yml))

## To-Do List

Use title case. ([Vale](../testing.md#vale) rule: [`ToDo.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/ToDo.yml))

## useful

Do not use. If the user doesn't find the process to be useful, we lose their trust.

## utilize

Do not use. Use **use** instead. It's more succinct and easier for non-native English speakers to understand.

## Value Stream Analytics

Title case.

## via

Do not use Latin abbreviations. Use **with**, **through**, or **by using** instead. ([Vale](../testing.md#vale) rule: [`LatinTerms.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/LatinTerms.yml))

## we

Try to avoid **we** and focus instead on how the user can accomplish something in GitLab.

- Avoid: We created a feature for you to add widgets.
- Instead, use: Use widgets when you have work you want to organize.

One exception: You can use **we recommend** instead of **it is recommended** or **GitLab recommends**.

## whitelist

Do not use. Another option is **allowlist**. ([Vale](../testing.md#vale) rule: [`InclusionCultural.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/InclusionCultural.yml))

<!-- vale on -->
<!-- markdownlint-enable -->
