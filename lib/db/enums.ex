import EctoEnum

# loans
defenum Tokenizer.DB.Enums.PaymentStatuses,
  :payment_status, ["authorization", "completed", "processing", "declined", "error"]

defenum Tokenizer.DB.Enums.AuthTypes,
  :auth_type, ["3d_secure", "lookup_code"]

defenum Tokenizer.DB.Enums.PeerTypes,
  :peer_type, ["card"] # :token is supported on controller level

# TODO: SenderTypes: card, token
# TODO: RecipientTypes: card, token, external_key
