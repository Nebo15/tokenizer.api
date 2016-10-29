import EctoEnum

# loans
defenum Tokenizer.DB.Enums.PaymentStatuses,
  :payment_status, ["authorization", "completed", "processing", "declined", "error"]

defenum Tokenizer.DB.Enums.AuthTypes,
  :auth_type, ["3d-secure", "lookup-code"]

defenum Tokenizer.DB.Enums.AccountCredential,
  :account_credential, ["card", "card-number", "card-token", "external-credential"]
