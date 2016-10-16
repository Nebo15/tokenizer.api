import EctoEnum

# loans
defenum Tokenizer.DB.Enums.PaymentStatuses,
  :payment_status, ["authorization", "completed", "processing", "declined", "error"]

defenum Tokenizer.DB.Enums.PeerTypes,
  :payment_status, ["card"] # :token is supported on controller level
