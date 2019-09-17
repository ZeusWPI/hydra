import transaction_parser
import pandas as pd
import crowdinator
import datetime
from fbprophet import Prophet
from fbprophet.plot import add_changepoints_to_plot
import matplotlib.pyplot as plt


from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

def time_to_seconds(time):
    return time.hour * 3600 + time.minute * 60 + time.second

if __name__ == '__main__':
    # raw_transactions = read_files('sterre', 'raw-data/csv/', 'processed-data')
    # raw_transactions = pd.read_csv('processed-data/sterre.csv', parse_dates=['timestamp'])

    # transactions = transaction_parser.parse_transactions(raw_transactions, 'sterre', 'raw-data/menu/nl')
    # durations = crowdinator.calculate_times(transactions, 'processed-data/sterre-durations.csv')
    # durations = pd.read_csv('processed-data/sterre-durations.csv', parse_dates=['timestamp'])
    # crowds = crowdinator.calculate_crowds(durations, [["11:15", "14:00"]], 'processed-data/result-sterre.csv')
    crowds = pd.read_csv('processed-data/result-sterre.csv', parse_dates=['timestamp'])
    crowdsTest = pd.read_csv('processed-data/result-sterre2-test.csv', parse_dates=['timestamp'])

    plt.interactive(False)

    crowds.plot(x = 'timestamp', y='crowd', kind='bar')
    plt.show()


