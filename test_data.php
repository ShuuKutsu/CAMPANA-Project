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

    $floodRisk = "none"; // Default value
    $chanceOfRain = "none"; // Default value
    $stormSignal = "No Storm";
    $temperatureDesc = "none";
    $chanceOfFlood = "none";
    $floodWaterLevel = "No Flood";

    // Range of Flood Level

    if ($waterlevel < 480){ 
        $floodWaterLevel = "No Flood"; 
    } elseif ($waterlevel >= 481 && $waterlevel <= 530){ 
        $floodWaterLevel = "Water level 6.5 cm"; 
    } elseif ($waterlevel >= 531 && $waterlevel <= 615){ 
        $floodWaterLevel = "Water level 7 cm"; 
    } elseif ($waterlevel >= 616 && $waterlevel <= 660){ 
        $floodWaterLevel = "Water level 7.5 cm"; 
    } elseif ($waterlevel >= 661 && $waterlevel <= 680){ 
        $floodWaterLevel = "Water level 8 cm"; 
    } elseif ($waterlevel >= 681 && $waterlevel <= 690){ 
        $floodWaterLevel = "Water level 8.5 cm"; 
    } elseif ($waterlevel >= 691 && $waterlevel <= 700){ 
        $floodWaterLevel = "Water level 9 cm"; 
    } elseif ($waterlevel >= 701 && $waterlevel <= 705){ 
        $floodWaterLevel = "Water level 9.5 cm"; 
    } elseif ($waterlevel >= 706){ 
        $floodWaterLevel = "Water level 10 cm"; 
    }

    // Evaluate chance of flood
    if ($amountofrain < 7.5) {
        $chanceOfFlood = "Low";
    } elseif ($amountofrain >= 7.6 && $amountofrain <= 15) {
        $chanceOfFlood = "Moderate";
    } elseif ($amountofrain >= 15.1 && $amountofrain <= 30) {
        $chanceOfFlood = "High";
    } elseif ($amountofrain >= 30.1) {
        $chanceOfFlood = "Very High";
    }

    // Evaluate chance of rain
    if ($humidity < 60) {
        $chanceOfRain = "Very Low Chance";
    } elseif ($humidity >= 60 && $humidity <= 80) {
        $chanceOfRain = "Moderate Chance";
    } elseif ($humidity >= 81 && $humidity <= 90) {
        $chanceOfRain = "High Chance";
    } elseif ($humidity >= 91) {
        $chanceOfRain = "Very High Chance";
    }

    //Evaluate Temperature
    if ($temperature < 20) {
      $temperatureDesc = "Cool";
    } elseif($temperature >= 21 && $temperature <= 26) {
      $temperatureDesc = "Mild or Comfortable"; 
    } elseif($temperature >= 27 && $temperature <= 30) {
      $temperatureDesc = "Warm"; 
    } elseif($temperature >= 31 && $temperature <= 40) {
      $temperatureDesc = "Hot"; 
    } elseif($temperature >= 41) {
      $temperatureDesc = "Extremely Hot"; 
    } 

    // Wind Description 
    if ($windspeed <= 29) {
        $stormSignal = "No Storm";
    } elseif ($windspeed >= 30 && $windspeed <= 60) {
        $stormSignal = "Signal #1";
    } elseif ($windspeed >= 61 && $windspeed <= 120) {
        $stormSignal = "Signal #2";
    } elseif ($windspeed >= 121 && $windspeed <= 170) {
        $stormSignal = "Signal #3";
    } elseif ($windspeed >= 171 && $windspeed <= 220) {
        $stormSignal = "Signal #4";
    } elseif ($windspeed >= 221) {
        $stormSignal = "Signal #5";
    }

    // Insert data into database
    $sql = "INSERT INTO sensors (temperature, humidity, amountofrain, waterlevel, windspeed, flood_risk, chance_of_rain, storm_signal, temperature_desc, chance_of_flood, flood_level) VALUES ('$temperature', '$humidity', '$amountofrain', '$waterlevel', '$windspeed', '$floodRisk', '$chanceOfRain', '$stormSignal', '$temperatureDesc', '$chanceOfFlood', '$floodWaterLevel')";

    if ($conn->query($sql) === TRUE) {
        echo "Data inserted successfully";

        // Prepare the data to be broadcasted
        $data = json_encode([
            'temperature' => $temperature,
            'humidity' => $humidity,
            'amountofrain' => $amountofrain,
            'waterlevel' => $waterlevel,
            'windspeed' => $windspeed,
            'flood_risk' => $floodRisk,
            'chance_of_rain' => $chanceOfRain,
            'storm_signal' => $stormSignal,
            'temperature_desc' => $temperatureDesc,
            'chance_of_flood' => $chanceOfFlood,
            'flood_level' => $floodWaterLevel,
        ]);

    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
} else {
    echo "No data received";
}

$conn->close();
?>

