import streamlit as st
import seaborn as sns
import matplotlib.pyplot as plt
from dbhelper import DB
from datetime import datetime


db = DB()

st.sidebar.image("train_quotes.jpg", use_container_width= True)

st.sidebar.title("🚆 Train Ticket Dashboard")

menu = st.sidebar.selectbox("Menu", options=['Select One', 'Check Tickets', 'Analytics'])

# Check Tickets Section

if menu == 'Check Tickets':
    st.title('Search Train Tickets')

    stations = db.fetch_station_names()

    col1, col2 = st.columns(2)

    with col1:
        source = st.selectbox('Source Station', sorted(stations))
    
    with col2:
        destination = st.selectbox('Destination Station', sorted(stations))

    if st.button('Search'):

        results = db.search_tickets(source, destination)

        if results:
            st.subheader(f"Tickets from {source} to {destination}")
            #st.dataframe(results)
            st.table(results)  # will show nice column headers!
        else:
            st.warning('No tickets found.')

# Analytics Section

elif menu == 'Analytics':
    st.title("📊 Booking Analytics")

    # Optional Filters
    st.subheader('Filters')
    all_classes = ['Sleeper', 'AC 2 Tier','AC 3 Tier', 'AC First Class']
    selected_class= st.multiselect('Select Class', options= all_classes, default= None)
    start_date = st.date_input("Start Date", datetime(2023, 1, 1))
    end_date = st.date_input("End Date", datetime(2023, 12, 31))

    # Pie Chart - Class Frequency

    labels, values = db.class_frequency()

    if labels and values:
        fig1, ax1 = plt.subplots()
        ax1.pie(values, labels= labels, autopct='%1.1f%%',startangle=140)
        ax1.axis('equal')
        st.subheader('Class Distribution')
        st.pyplot(fig1)
        st.markdown(f"✅ **Conclusion:** The most booked class is **{labels[values.index(max(values))]}**, indicating a strong preference among passengers.")

    # Bar Chart - Station Wise Bookings

    stations, bookings = db.station_wise_booking()

    if stations and bookings:
        fig2, ax2 = plt.subplots()
        sns.barplot(x=bookings,y=stations, ax=ax2, palette='viridis')
        ax2.set_xlabel("Number of Bookings")
        ax2.set_ylabel("Source Station")
        st.subheader('Top Boarding Stations')
        st.pyplot(fig2)
        st.markdown(f"📍 **Conclusion:** The station with the highest number of departures is **{stations[0]}**, highlighting its role as a major boarding hub.")

    # Line Chart - Daily Bookings

    dates, counts = db.daily_bookings()

    if dates and counts:
        fig3, ax3 = plt.subplots()
        sns.lineplot(x=dates,y=counts, ax=ax3, palette='green')
        ax3.set_xlabel("Date")
        ax3.set_ylabel("No. of Bookings")
        plt.xticks(rotation=75)
        st.subheader('📅 Bookings Over Time')
        st.pyplot(fig3)
        st.markdown("📈 **Conclusion:** The booking trend shows peaks and troughs, indicating seasonal or event-based travel patterns.")

    # Line Chart - Revenue Over Time

    st.subheader("💰 Revenue Over Time")

    rev_dates, rev_values = db.revenue_over_time()

    if rev_dates and rev_values:
        fig4, ax4 = plt.subplots()
        sns.lineplot(x=rev_dates, y=rev_values, markers='o' ,ax= ax4, color= 'orange')
        ax4.set_xlabel("Date")
        ax4.set_ylabel("Total Revenue")
        plt.xticks(rotation=85)
        st.pyplot(fig4)
        st.markdown("💹 **Conclusion:** Revenue follows a trend similar to bookings, with noticeable spikes likely driven by peak travel days.")


        
        # Peak Booking Day
        st.subheader("🔥 Peak Booking Day")

        # Find the index of the maximum revenue value
        max_index = rev_values.index(max(rev_values))

        # Get the corresponding date for that maximum revenue
        peak_day = rev_dates[max_index]

        
        #st.success(f"Highest Revenue Day: {peak_day} with ₹{rev_values[max_index]}")

        # Display the result
        st.success(f"Highest Revenue Day: {peak_day} with ₹{rev_values[max_index]:,}")

# Welcome Section
else:
    st.title("Welcome to the Train Ticket Dashboard 🚉")
    st.image("train_logo.jpg", use_container_width=True)
    st.markdown("""
        ## Features
        - 🔍 Search tickets by source & destination
        - 📊 Visual analytics (class distribution, top stations, booking trends)
        - 💰 Revenue insights and peak booking dates
        - 📅 Filters by class and date range

        ### Built with ❤️ by **Kaustav Roy Chowdhury** using Streamlit, Seaborn, MySQL 
    """)
