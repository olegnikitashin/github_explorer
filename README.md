# NOTES

## This document contains

- [Installation](#installation)
- [How it Works](#how-it-works)
- [Considerations](#considerations)
- [Future Enhancements](#future-enhancements)
- [Preparing for Production](#preparing-for-production)
- [API Specification](#api-specification)

## Installation

To test the service under real conditions, you need to register with Github to obtain your API access token. This token should be added to your `.env` file as `GITHUB_ACCESS_TOKEN`. For more information, visit [Github](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).

Docker Compose is the recommended method for local installation:

1. ensure Docker and Docker Compose are installed on your machine. Follow the installation guide [how to](https://docs.docker.com/get-docker/)
2. create a copy of the environment variables template: `cp .env.sample .env` and customize as needed
3. build the Docker containers with: `docker-compose build`
4. launch the service using: `docker-compose up`
5. execute tests by running: `docker-compose run --rm -e RAILS_ENV=test api rspec`

## How it works

This Sinatra application provides a `/api/v1/search` endpoint for querying GitHub repositories, using Redis for caching responses and using a combination of custom services for parameter validation, request processing, and response serialization.

1. a GET request to `/api/v1/search` starts the process, serving as the primary entry point for repository searches
2. the `RepositoriesController` accepts the request and passes the query parameters to the `ValidateParams` service for validation
3. this service validates the parameters against predefined criteria, ensuring they meet the requirements for a valid search query
4. once validated, the `PrepareParams` service structures the parameters appropriately for the GitHub API query
5. the `Fetch` service then attempts to retrieve a cached response for the query from Redis. If unavailable or expired, it proceeds to query the GitHub API
6. the GitHub API response is passed to the `Serialize` service, which transforms the data into a simplified format, focusing on repository name, author, URL, and star rating
7. before returning the serialized response to the client, it is cached in Redis with a TTL (Time to Live) of 1 hour to optimize future requests for the same data
8. finally, the service responds to the client with either the serialized search results in a `200 OK` response for successful queries or an error message with a `422 Unprocessable Entity` status for invalid requests

## Considerations

### Framework selection

Sinatra was the ideal choice due to its simplicity and efficiency. It offers just what's needed to build a web application, allowing to get something workable in minutes. It does not load as many middleware or dependencies as Rails, which can lead to better performance especially needed for high load environments. The reduced overhead means the application can handle requests faster and with less resource consumption.

### Enhancing Web Server Throughput

While Sinatra is efficient, it may struggle under heavy loads in a single-threaded setup. The service utilizes Puma, a multi-threaded server, enabling horizontal scaling with multiple instances to improve response times and manage increased traffic effectively.

### Caching GitHub Responses with Redis

To optimize API response times and reduce redundant requests to GitHub, the service caches serialized GitHub responses using Redis. By employing an LRU (Least Recently Used) cache strategy, it ensures that only the most relevant data is stored, automatically removing the least recently accessed items when the memory limit is reached. This approach, combined with a default TTL (Time to Live) of 3600 seconds(1 hour) for cached items, to balance between freshness and efficiency of the data. The Redis setup, configured via `docker-compose` to use a maximum of 200MB memory and the `volatile-lru` policy.

### Rate Limiting with Rack-Attack

The service utilizes `rack-attack` to enforce rate limiting, enhancing security and ensuring fair resource distribution. It's configured to allow 30 requests per IP every 60 seconds, effectively mitigating excessive use and preventing abuse. Exceeding this limit triggers a `429 Too Many Requests` response, prompting users to retry later. This setup uses Redis for efficient rate tracking across application instances.

### Pagination

The service supports pagination, allowing users to navigate through large datasets efficiently by using `page` and `per_page` query parameters. `per_page` parameter equals to 30 by default.

### Efficient JSON parsing with Oj

To optimize performance under high load, the Oj library is used, one of Ruby's fastest JSON parsers.

## Future Enhancements

- consider more edge cases, handling various Github API error cases
- perform some load testing to identify and address potential bottlenecks

## Preparing for Production

In order to prepare the service for production I would consider the following steps.

### Performance and Reliability

- run Puma in cluster mode, utilizing multiple worker processes to improve concurrency and throughput
- employ a load balancer to distribute incoming traffic evenly across instances, enhancing the service's ability to handle high loads efficiently
- use containerization with Docker for easy deployment and some orchestration tool(like Kubernetes), ensuring high availability and scalability
- implement auto-scaling based on performance metrics like CPU usage, memory consumption, and request load, ensuring the service can adapt to varying loads automatically
- configure health checks to monitor the health of each service instance, allowing for automatic replacement of unhealthy instances

### Logging, Monitoring, and Error Handling

- use comprehensive, structured logging to simplify log analysis and querying
- utilize tools like Prometheus, Grafana, or Datadog to monitor service metrics and set up alerts for anomalies, ensuring quick response to potential issues
- integrate with platforms like Sentry or Rollbar for efficient error tracking and exception management
- establish a process for conducting postmortem analyses to learn from incidents and prevent future occurrences

### Security

- ensure the service is accessible via a secure HTTPS address, with a valid SSL certificate from a trusted authority, to protect against man-in-the-middle attacks
- implement strong authentication mechanisms to protect the endpoint from unauthorized access

## API Specification

### Endpoint: Search Repositories

#### Description

This endpoint searches for public repositories on GitHub based on provided search criteria.

#### URL

`GET /api/v1/search`

#### Parameters

- `query` (string, required): The search keyword(s) for repositories.
- `sort` (string, optional): Field to sort the results by. Can be `stars` or `name`. Defaults to sorting by stars.
- `order` (string, optional): Sorting order, either `asc` for ascending or `desc` for descending. Default is `desc`.
- `page` (integer, optional): Page number of the search results to fetch.
- `per_page` (integer, optional): Number of results per page. Default is 10.

#### Success Response

**Status code**: `200 OK`

**Content**:

```json
[
  {
    "name": "rails",
    "author": "rails",
    "url": "https://github.com/rails/rails",
    "stars": 123456
  }
  // Additional repository objects...
]
```

#### Error Response

**Condition**: If any required parameter is missing or invalid.

**Status code**: `422 Unprocessable Entity`

**Content**:

```json
{
  "errors": {
    "query": ["is missing"]
    // Additional error messages...
  }
}
```

Example Request

```bash
curl -X GET "http://localhost:3000/api/v1/search?query=rails&sort=stars&order=desc&page=1&per_page=10"
```
