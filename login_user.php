
<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
// Enable error reporting for debugging
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Database connection parameters
$host = "localhost";
$user = "root";
$pass = "";
$db = "signup_user";
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

// Receive JSON input
$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Log received data
error_log("Received data: " . print_r($data, true));

// Check if email and password are set
if (!isset($data['email']) || !isset($data['password'])) {
    echo json_encode(["status" => "error", "message" => "Email and password are required"]);
    exit;
}

$email = $data['email'];
$password = $data['password'];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
    
    // Check if user exists and password is correct
    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if ($user && password_verify($password, $user['password'])) {
        // Login successful
        echo json_encode([
            "status" => "success", 
            "message" => "Login successful",
            "user" => [
                "id" => $user['id'],
                "email" => $user['email']
                // Add any other user data you want to send back to the app
            ]
        ]);
    } else {
        // Login failed
        echo json_encode(["status" => "error", "message" => "Invalid email or password"]);
    }
} catch (\PDOException $e) {
    error_log("Database error: " . $e->getMessage());
    echo json_encode(["status" => "error", "message" => "Database error occurred"]);
}