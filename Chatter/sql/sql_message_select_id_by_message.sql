SELECT
  id

FROM
  message

WHERE
  timestamp=? AND
  session_id=? AND
  account_id=(SELECT id FROM account WHERE screenname=?) AND
  message=?

