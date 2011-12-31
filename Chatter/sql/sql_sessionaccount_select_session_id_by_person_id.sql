SELECT
  session_id

FROM
  sessionaccount

WHERE
  account_id IN (SELECT id FROM account WHERE person_id=?)

