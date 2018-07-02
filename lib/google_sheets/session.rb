require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

module GoogleSheets
  class Session
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    # APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'.freeze
    CLIENT_SECRETS_PATH = 'client_secret.json'.freeze
    CREDENTIALS_PATH = 'token.yaml'.freeze
    SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

    ##
    # Ensure valid credentials, either by restoring from the saved credentials
    # files or intitiating an OAuth2 authorization. If authorization is required,
    # the user's default browser will be launched to approve the request.
    #
    # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
    def authorize
      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: OOB_URI)
        puts "Open the following URL in the browser and enter the resulting code after authorization:\n #{url}"

        code = STDIN.gets

        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI
        )
      end
      credentials
    end

    def self.start_session
      # Initialize the API
      service = Google::Apis::SheetsV4::SheetsService.new
      # service.client_options.application_name = APPLICATION_NAME
      service.authorization = authorize
    end
  end
end
