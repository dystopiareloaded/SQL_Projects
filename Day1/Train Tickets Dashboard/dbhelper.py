import streamlit as st
import mysql.connector
import psycopg2

class DB:
    def __init__(self):
        try:
            self.conn = psycopg2.connect(
                host=st.secrets["supabase"]["host"],
                user=st.secrets["supabase"]["user"],
                password=st.secrets["supabase"]["password"],
                dbname=st.secrets["supabase"]["dbname"],
                port=st.secrets["supabase"]["port"]
            )
            self.cursor = self.conn.cursor()
            print("✅ Supabase DB connected")
        except Exception as e:
            print("❌ Connection failed:", e)

    
    def fetch_station_names(self):

        station = []

        self.cursor.execute("""
        SELECT DISTINCT(source) FROM train_tickets
        UNION
        SELECT DISTINCT(destination) FROM train_tickets
        """)

        data = self.cursor.fetchall()

        for row in data:
            station.append(row[0])

        return station
    
    def search_tickets(self, source, destination):

        self.cursor.execute("""
            SELECT train_id, train_name, class, days_of_operation FROM train_tickets
            WHERE source = '{}' AND destination = '{}'
        """.format(source, destination))

        data = self.cursor.fetchall()

        # Get column names from cursor
        column_names = [desc[0] for desc in self.cursor.description]

        # Convert rows to list of dictionaries
        result = [dict(zip(column_names, row)) for row in data]

        return result
    
    def class_frequency(self):
        labels = []
        values = []

        self.cursor.execute("""

        SELECT class, COUNT(*) FROM train_tickets
        GROUP BY class
        """)

        data = self.cursor.fetchall()

        for row in data:
            labels.append(row[0])
            values.append(row[1])

        return labels, values
    
    def station_wise_booking(self):

        stations = []
        bookings = []

        self.cursor.execute("""
        SELECT source, COUNT(*) AS Bookings
        FROM train_tickets
        GROUP BY source
        ORDER BY Bookings DESC
        """)

        data = self.cursor.fetchall()

        for row in data:
            stations.append(row[0])
            bookings.append(row[1])

        return stations, bookings

    def daily_bookings(self):

        dates = []
        counts = []

        self.cursor.execute("""
        SELECT travel_date, COUNT(*) AS Bookings FROM train_tickets
        GROUP BY travel_date
        ORDER BY travel_date
        """)

        data = self.cursor.fetchall()
        

        for row in data:
            dates.append(str(row[0]))
            counts.append(row[1])
        
        return dates, counts
    
    def revenue_over_time(self):

        rev_dates = []
        rev_values = []

        self.cursor.execute("""
        SELECT travel_date, SUM(price) as total_revenue FROM train_tickets
        GROUP BY travel_date
        ORDER BY travel_date
        """)

        data = self.cursor.fetchall()

        for row in data:

            rev_dates.append(str(row[0]))
            rev_values.append(row[1])

        return rev_dates, rev_values
    
    

