AWS_REGION="us-east-1" # Rep
ENV_FILE="appconfig.env"
APPLICATION_ID="chatbot-production"           # Replace with your application ID
ENVIRONMENT_ID="production"                   # Replace with your environment ID
CONFIGURATION_PROFILE_ID="chatbot-production" # Replace with your configuration profile ID

if [ ! -s "$ENV_FILE" ]; then
  aws appconfig get-configuration --application $APPLICATION_ID --environment $ENVIRONMENT_ID --configuration $CONFIGURATION_PROFILE_ID --client-id $(uuidgen) --region $AWS_REGION $ENV_FILE
fi

if [ ! -s "$ENV_FILE" ]; then
  echo "Failed to retrieve configuration data"
  exit 1
fi

export $(grep -v '^#' "$ENV_FILE" | xargs)
