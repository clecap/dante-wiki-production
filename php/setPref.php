<?php

// Set your MediaWiki URL and user credentials
$mediawikiUrl = 'https://iuk-stage.informatik.uni-rostock.de/wiki-dir/';
$username = 'Admin';
$password = 'adminadmin';

// User whose preference you want to set
$userToSetPreference = 'Admin';

// Preference to set
$preferenceName  = 'aws-accesskey'; // Example preference
$preferenceValue = 'onekey'; // Example value

// Prepare request parameters
$params = array('action' => 'options', 'format' => 'json', 'user' => $userToSetPreference, 'token' => getToken($mediawikiUrl, $username, $password), $preferenceName => $preferenceValue);

// Make API request to set user preference
$result = apiRequest($mediawikiUrl, $params);

// Function to get CSRF token
function getToken($url, $username, $password) {
  $params = array('action' => 'query',  'meta' => 'tokens',  'type' => 'login',  'format' => 'json');
  $token = apiRequest($url, $params);
  $params = array('action' => 'login', 'lgname' => $username, 'lgpassword' => $password, 'lgtoken' => $token['query']['tokens']['logintoken'], 'format' => 'json' );
  $result = apiRequest($url, $params);
  return $result['login']['token'];
}

// Function to make API request
function apiRequest($url, $params) {
  $ch = curl_init();
  curl_setopt($ch, CURLOPT_URL, $url);
  curl_setopt($ch, CURLOPT_POST, true);
  curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($params));
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  $response = curl_exec($ch);
  curl_close($ch);
  return json_decode($response, true);
}

// Output result
var_dump($result);