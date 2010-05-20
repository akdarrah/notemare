# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_min_session',
  :secret      => '71a2963168c409d7b7a208eec33e9f4f312e2f02735d067139703d13d8e2752ecdd34d763500bc8487667cd53970cfe4739e0b4e75b16058da36fcbf3473c967'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
