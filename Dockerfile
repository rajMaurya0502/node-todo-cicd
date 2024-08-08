# FROM node:12.2.0-alpine
# WORKDIR app
# COPY . .
# RUN npm install
# RUN npm run test
# EXPOSE 8000
# CMD ["node","app.js"]

FROM public.ecr.aws/lambda/nodejs:18

COPY . ${LAMBDA_TASK_ROOT}

# --- Begin of enable Dynatrace OneAgent monitoring section

# environment variables copied from Dynatrace AWS Lambda deployment screen
# (prefix with ENV and remove spaces around equal signs)
ENV AWS_LAMBDA_EXEC_WRAPPER=/opt/dynatrace
ENV DT_TENANT=vti61510
ENV DT_CLUSTER_ID=445768248
ENV DT_CONNECTION_BASE_URL=https://vti61510.live.dynatrace.com
ENV DT_CONNECTION_AUTH_TOKEN=dt0a01.vti61510.f333343f864e830f4019351fe14455540726e066c67266e77ea286916feb780f
ENV DT_OPEN_TELEMETRY_ENABLE_INTEGRATION=true

RUN curl $(aws --region us-east-1 lambda get-layer-version-by-arn --arn arn:aws:lambda:us-east-1:725887861453:layer:Dynatrace_OneAgent_1_295_3_20240729-145043_nodejs:1 --query 'Content.Location' --output text) --output layer.zip

RUN unzip -d DynatraceOneAgentExtension layer.zip

# copy Dynatrace OneAgent extension download and extracted to local disk into container image
COPY DynatraceOneAgentExtension/ /opt/

# make /opt/dynatrace shell script executable
RUN chmod +x /opt/dynatrace

# --- End of enable Dynatrace OneAgent monitoring section

CMD [ "index.handler" ]
