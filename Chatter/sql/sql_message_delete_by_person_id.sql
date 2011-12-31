DELETE FROM
  message

WHERE
  account_id IN (SELECT id FROM account WHERE person_id=?)
