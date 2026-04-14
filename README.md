# GCP Memorystore for Valkey

This Nullstone module creates a GCP Memorystore instance running Valkey.
Additionally, this module creates resources that are necessary to securely connect apps via Nullstone.

## How it is configured

The Valkey instance is provisioned on the project's VPC via Private Service Connect (PSC) so that
communication between your apps and the instance happens over a private networking connection.
This enables lower latency and more secure communication.

This module follows Google's guidance for configuring Memorystore for Valkey with PSC:

- [Networking for Memorystore for Valkey](https://cloud.google.com/memorystore/docs/valkey/networking)
- [Create a service connection policy](https://cloud.google.com/memorystore/docs/valkey/create-service-connection-policy)
- [Create an instance](https://cloud.google.com/memorystore/docs/valkey/create-instance)
