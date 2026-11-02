# Permissions — who may do what

Authorization is enforced by Pundit policies in `app/policies/`. Each table below
says what each role may do with a resource, and under which condition. The policies
and these tables are kept in step: a rule here is enforced by a policy method, and a
policy method is shown here.

The three roles are `owner`, `mechanic` and `counter`. "Public" means the action is
open to everyone, including a visitor with no account.

## Services (the price list)

| Action            | Owner | Counter | Mechanic | Condition |
|-------------------|:-----:|:-------:|:--------:|-----------|
| list (`index`)    |  ✅   |   ✅    |   ✅     | public — open to everyone |
| view (`show`)     |  ✅   |   ✅    |   ✅     | public — open to everyone |
| create            |  ✅   |   ❌    |   ❌     | — |
| edit (`update`)   |  ✅   |   ❌    |   ❌     | — |
| delete (`destroy`)|  ✅   |   ❌    |   ❌     | — |

## Staff

| Action            | Owner | Counter | Mechanic | Condition |
|-------------------|:-----:|:-------:|:--------:|-----------|
| list / view       |  ✅   |   ✅    |   ✅     | every signed-in role reads staff |
| create            |  ✅   |   ❌    |   ❌     | — |
| edit              |  ✅   |   ❌    |   ❌     | — |
| delete            |  ✅   |   ❌    |   ❌     | the model also refuses if the member has an account |

## Customers and Bikes

| Action            | Owner | Counter | Mechanic | Condition |
|-------------------|:-----:|:-------:|:--------:|-----------|
| list / view       |  ✅   |   ✅    |   ❌     | a mechanic has no access (403) |
| create            |  ✅   |   ✅    |   ❌     | — |
| edit              |  ✅   |   ✅    |   ❌     | — |
| delete            |  ✅   |   ❌    |   ❌     | only the owner deletes |

## Repairs

| Action            | Owner | Counter | Mechanic | Condition |
|-------------------|:-----:|:-------:|:--------:|-----------|
| list (`index`)    |  ✅   |   ✅    |   ✅     | owner & counter see every repair; a mechanic sees **only the repairs assigned to them** (a policy scope) |
| view (`show`)     |  ✅   |   ✅    |  own     | a mechanic opens only their own repairs; another's answers 403 |
| take in (`create`)|  ✅   |   ✅    |   ❌     | — |
| edit (`update`)   | any   | any **not handed back** | **own, not handed back** | once a repair is handed back (final state, `collected`), only the owner edits it |
| delete (`destroy`)|  ✅   |   ❌    |   ❌     | — |

### Which fields each role writes on a repair

The repair form is shared; the policy's `permitted_attributes` decides the fields.

| Role            | Fields they may write |
|-----------------|-----------------------|
| owner, counter  | bike, mechanic, status, received/promised/handed-back dates, diagnosis, service lines and their prices, intake photos |
| mechanic        | status, diagnosis, intake photos — **nothing else** |

The account that took a repair in is always read from the session; it is never a
form field, for any role.
