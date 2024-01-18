FROM public.ecr.aws/lambda/python:3.12

# Install Tailscale Extension
# Curl Already exists in this version
# But as it's required for the tailscale extension so is left
# RUN dnf install -y curl
COPY --from=ghcr.io/rails-lambda/tailscale-extension-amzn:1 /opt /opt

# Copy requirements.txt
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Install the specified packages
RUN pip install -r requirements.txt

# Copy function code
COPY lambda_function.py ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "lambda_function.handler" ]