import jwt
import datetime

secret = "super-secret-jwt-token-for-supabase-local-at-least-32-chars"
now = datetime.datetime.utcnow()
exp = now + datetime.timedelta(days=365*10)  # 10 years

# ANON_KEY
payload_anon = {
    "role": "anon",
    "iss": "default",
    "iat": int(now.timestamp()),
    "exp": int(exp.timestamp())
}
anon_key = jwt.encode(payload_anon, secret, algorithm="HS256")
print("ANON_KEY:", anon_key)

# SERVICE_ROLE_KEY
payload_service = {
    "role": "service_role",
    "iss": "default",
    "iat": int(now.timestamp()),
    "exp": int(exp.timestamp())
}
service_key = jwt.encode(payload_service, secret, algorithm="HS256")
print("SERVICE_ROLE_KEY:", service_key)