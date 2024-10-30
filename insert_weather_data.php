<?php

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "campana_sensor-readings";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Retrieve data sent via POST
if (isset($_POST['temperature']) && isset($_POST['humidity']) && isset($_POST['amountofrain']) && isset($_POST['waterlevel']) && isset($_POST['windspeed'])) 
{

    $temperature = $_POST['temperature'];
    $humidity = $_POST['humidity'];
    $amountofrain = $_POST['amountofrain'];
    $waterlevel = $_POST['waterlevel'];
    $windspeed = $_POST['windspeed'];

    // Insert data into database
    $sql = "INSERT INTO sensors (temperature, humidity, amountofrain, waterlevel, windspeed) VALUES ('$temperature', '$humidity', '$amountofrain', '$waterlevel', '$windspeed')";

    if ($conn->query($sql) === TRUE) {
        echo "Data inserted successfully";

        // Prepare the data to be broadcasted
        $data = json_encode([
            'temperature' => $temperature,
            'humidity' => $humidity,
            'amountofrain' => $amountofrain,
            'waterlevel' => $waterlevel,
            'windspeed' => $windspeed,
        ]);

    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
} else {
    echo "No data received";
}

$conn->close();
?>
