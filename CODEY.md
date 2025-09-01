## Making changes to the codebase

- If the user asks to make changes to the codebase and create a pull request (PR), you MUST commit the changes to a feature branch first, then push the branch to the remote repository. Once you've done those, you may create a PR.
- Commit messages must be written in the style of a conventional commit message. If possible, you should include a reference to the Devops Center Work Item (WI) that this change is related to.

## Making Pull Requests (PRs)

- When making a PR, you must ensure that any changes you've made have been committed to a feature branch first, then pushed to the remote repository. Once you've done those, you may create a PR.
- You must follow the PR description template below to the best of your ability.

**PR Description Template:**

---

**Title:** [Concise summary of the change]

**Summary**

- Briefly describe what this PR does and why these changes are necessary.

**Related Issue(s)**

- Resolves WI-XXXXXXX (Devops Center Work Item)

**Changes**

- List the main changes introduced in this PR, for example:
    - Added/modified/deleted [feature/file/functionality]
    - Refactored [component/module]
    - Fixed [bug/issue]

**Additional Notes**

- Add any extra context, concerns, or follow-up tasks here.

---

## Common Acronyms

- RCA: Root Cause Analysis
- SOQL: Salesforce Object Query Language
- WI: A DevOps Center Work Item
- PR: Pull Request

## Root Cause Analysis (RCA)

- When you are asked to perform an RCA, you must follow the RCA template below to the best of your ability.
- All markdown must be formatted for Slack using `mrkdwn` format.

**RCA Template:**

---

**Title:** [Concise incident title]

**Date/Time (TZ):** [YYYY-MM-DD HH:MM – HH:MM]

**Summary**

- One to three sentences describing what happened and the user/business impact.

**Impact**

- Affected users/systems:
- Severity and duration:
- Business impact (SLA/SLO, revenue, ops):

**Timeline (all times in TZ)**

- YYYY-MM-DD HH:MM – Event description
- YYYY-MM-DD HH:MM – Detection/alert
- YYYY-MM-DD HH:MM – Mitigation started
- YYYY-MM-DD HH:MM – Service restored
- YYYY-MM-DD HH:MM – Root cause identified

**Detection**

- How was it detected?
- What signals were missed or noisy?

**Root Cause**

- Immediate cause:
- Underlying cause:
- Contributing factors:
- 5 Whys:
    - Why 1:
    - Why 2:
    - Why 3:
    - Why 4:
    - Why 5:

**Mitigation and Recovery**

- Short-term mitigations applied:
- Data integrity/recovery steps:
- Time to mitigate / time to recover:

**Corrective and Preventative Actions (CAPA)**

- Short-term actions (next 1–2 weeks):
    - [ ] Action — Owner — Due
- Long-term actions:
    - [ ] Action — Owner — Due
- Monitoring/alerting improvements:
    - [ ] Action — Owner — Due
- Process/knowledge improvements:
    - [ ] Action — Owner — Due

**Lessons Learned**

- What went well:
- What didn’t go well:
- Surprises/gaps:

**Attachments/References**

- Dashboards:
- Logs/trace IDs:
- PRs/changes:
- Work Items:

---
