#!/bin/bash

# Set the threshold values for CPU and memory usage (in percentage)
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80

# Set the email address to receive alerts
EMAIL="your_email@example.com"

# Function to check CPU usage
check_cpu_usage() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    if [ $(echo "$cpu_usage >= $CPU_THRESHOLD" | bc) -eq 1 ]; then
        send_alert "High CPU usage detected: $cpu_usage%"
    fi
}

# Function to check memory usage
check_memory_usage() {
    memory_usage=$(free | awk '/Mem/{printf("%.2f"), $3/$2 * 100}')
    if [ $(echo "$memory_usage >= $MEMORY_THRESHOLD" | bc) -eq 1 ]; then
        send_alert "High memory usage detected: $memory_usage%"
    fi
}

# Function to send email alerts
send_alert() {
    subject="Alert: $1"
    echo "$1" | mail -s "$subject" "$EMAIL"
    echo "Alert sent: $subject"
}

# Main function
main() {
    check_cpu_usage
    check_memory_usage
}

# Execute main function
main
