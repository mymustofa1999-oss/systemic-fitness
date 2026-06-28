const axios = require('axios');
const api = axios.create({
  baseURL: "http://localhost:8080",
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMmI0ZjZkMjEtYzQ2Yi00N2YzLTkwNGYtODQ4MDEyOWJjNjFkIiwiZW1haWwiOiJ0ZXN0Y2xpZW50OTk5QGdtYWlsLmNvbSIsInJvbGUiOiJjbGllbnQiLCJpc3MiOiJmaXRjb2FjaC1hcGkiLCJzdWIiOiIyYjRmNmQyMS1jNDZiLTQ3ZjMtOTA0Zi04NDgwMTI5YmM2MWQiLCJleHAiOjE3ODM2NTA0OTksImlhdCI6MTc4MTA1ODQ5OX0.hXZt_wzQGjeJGQpqBC-uuvIMI92KMejY_ErwbjIMHxk"
  },
});
api.interceptors.response.use(
  (res) => res,
  (err) => {
    console.log("Interceptor caught error status:", err.response?.status);
    console.log("Interceptor caught error data:", err.response?.data);
    return Promise.reject(new Error(err.response?.data?.message || err.message));
  }
);
api.get("/api/v2/assessments/latest")
  .then(res => console.log("Promise resolved:", res.data))
  .catch(err => console.log("Promise rejected (caught):", err.message));
