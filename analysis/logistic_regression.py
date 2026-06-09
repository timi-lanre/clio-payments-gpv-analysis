import pandas as pd
import statsmodels.api as sm
from sklearn.preprocessing import StandardScaler

# Load data
df = pd.read_excel("Senior_Analyst_CS_Analytics___Payments___Case_Study_Data.xlsx")

# Target and features
df['is_payments_enabled'] = (df['payments_enabled'] == 'Yes').astype(int)
df['health_green'] = (df['health_score'] == 'Green').astype(int)
df['attended_webinar'] = (df['attended_payments_webinar'] == 'Yes').astype(int)

features = [
    'bills_per_month',
    'manage_utilization_score',
    'gtm_touches_last_90_days',
    'health_green',
    'nps_score',
    'attended_webinar',
    'tenure_months'
]

model_df = df[features + ['is_payments_enabled']].dropna()

# Standardize and fit
scaler = StandardScaler()
X_scaled = scaler.fit_transform(model_df[features])
X_scaled = sm.add_constant(X_scaled)

model = sm.Logit(model_df['is_payments_enabled'], X_scaled).fit()
print(model.summary())