#!/bin/bash

# Check if exactly two filenames are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
fi

input_file=$1
output_file=$2

# Check if input file exists
if [ ! -e "$input_file" ]; then
    echo "Error: Input file '$input_file' does not exist."
    exit 1
fi

# Extract unique cities from the input CSV file and write them to the output file
echo "------------------" >> "$output_file"
echo "Unique cities in the given data file:" >> "$output_file"
awk -F', ' 'NR>1 {print $3}' "$input_file" | sort | uniq >> "$output_file"

# Extract the details of the top three individuals with the highest salary
echo "------------------" >> "$output_file"
echo "Details of top 3 individuals with the highest salary: " >> "$output_file"
tail -n +2 "$input_file" | sort -t, -k4 -nr | head -n 3 >> "$output_file"

# Print formatting
echo "------------------" >> "$output_file"
echo "Details of average salary of each city: " >> "$output_file"
# Accumulate sum of salaries and count of individuals in a dictionary for each city then average them
awk -F ', ' 'NR>1 {
    sum[$3] += $4
    count[$3]++
} 
END {
    for (city in sum) {
        avg_salary = sum[city] / count[city]
        print "City: " city ", Salary: " avg_salary
    }
}' "$input_file" >> "$output_file"

# Calculate overall average
overall_avg_salary=$(awk -F ', ' 'NR>1 {
    sum += $4
    count++
} 
END {
    print sum/count
}' "$input_file")

# Print the details
echo "------------------" >> "$output_file"
echo "Details of individuals with a salary above the overall average salary: " >> "$output_file"

# if salary is greater than average print it in a single line
awk -F ', ' -v avg="$overall_avg_salary" '{
    if(NR > 1 && $4 > avg) {
        printf "%s  %s  %s  %s\n", $1, $2, $3, $4
        }
    }' "$input_file" >> "$output_file"

# Closing line
echo "------------------" >> "$output_file"