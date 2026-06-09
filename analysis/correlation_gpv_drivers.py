import pandas as pd

# Load data
df = pd.read_excel("Senior_Analyst_CS_Analytics___Payments___Case_Study_Data.xlsx")

# Filter to enabled accounts only
enabled = df[df['payments_enabled'] == 'Yes'].copy()

# Cast numeric fields
enabled['gpv_last_6mo_usd'] = pd.to_numeric(enabled['gpv_last_6mo_usd'], errors='coerce')
enabled['estimated_billing_vol_6mo_usd'] = pd.to_numeric(enabled['estimated_billing_vol_6mo_usd'], errors='coerce')
enabled['bills_per_month'] = pd.to_numeric(enabled['bills_per_month'], errors='coerce')
enabled['arr_usd'] = pd.to_numeric(enabled['arr_usd'], errors='coerce')
enabled['company_size_employees'] = pd.to_numeric(enabled['company_size_employees'], errors='coerce')

# Correlation with GPV
features = [
    'estimated_billing_vol_6mo_usd',
    'bills_per_month',
    'arr_usd',
    'company_size_employees'
]

correlations = enabled[features + ['gpv_last_6mo_usd']].corr()['gpv_last_6mo_usd'].drop('gpv_last_6mo_usd')
print("Correlation with GPV (enabled accounts only):")
print(correlations.round(2).sort_values(ascending=False))