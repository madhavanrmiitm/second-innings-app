#!/usr/bin/env python3
"""
Test script to verify caregiver request functionality for both family members and senior citizens.
"""

import json

import requests

BASE_URL = "http://127.0.0.1:8000/api"

# Test tokens (these would be real tokens in a real scenario)
FAMILY_TOKEN = "test_family_token_001"
SENIOR_CITIZEN_TOKEN = "test_senior_token_001"


def test_caregiver_requests_family_member():
    """Test caregiver requests functionality for family members."""
    print("Testing caregiver requests for family member...")

    headers = {"Authorization": f"Bearer {FAMILY_TOKEN}"}

    # Test getting caregiver requests
    response = requests.get(f"{BASE_URL}/me/caregiver-requests", headers=headers)
    print(f"GET /me/caregiver-requests (Family Member): {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
    else:
        print(f"Error: {response.text}")

    # Test requesting a caregiver
    payload = {"caregiver_id": 1, "message": "Need assistance with daily activities"}
    response = requests.post(
        f"{BASE_URL}/me/request-caregiver", headers=headers, json=payload
    )
    print(f"POST /me/request-caregiver (Family Member): {response.status_code}")
    if response.status_code == 201:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
    else:
        print(f"Error: {response.text}")


def test_caregiver_requests_senior_citizen():
    """Test caregiver requests functionality for senior citizens."""
    print("\nTesting caregiver requests for senior citizen...")

    headers = {"Authorization": f"Bearer {SENIOR_CITIZEN_TOKEN}"}

    # Test getting caregiver requests
    response = requests.get(f"{BASE_URL}/me/caregiver-requests", headers=headers)
    print(f"GET /me/caregiver-requests (Senior Citizen): {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
    else:
        print(f"Error: {response.text}")

    # Test requesting a caregiver
    payload = {"caregiver_id": 1, "message": "Need assistance with daily activities"}
    response = requests.post(
        f"{BASE_URL}/me/request-caregiver", headers=headers, json=payload
    )
    print(f"POST /me/request-caregiver (Senior Citizen): {response.status_code}")
    if response.status_code == 201:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
    else:
        print(f"Error: {response.text}")


def test_accept_reject_caregiver_requests():
    """Test accepting and rejecting caregiver requests."""
    print("\nTesting accept/reject caregiver requests...")

    # Test for family member
    headers = {"Authorization": f"Bearer {FAMILY_TOKEN}"}

    # Test accepting a request
    payload = {"request_id": 1}
    response = requests.post(
        f"{BASE_URL}/me/accept-caregiver-request", headers=headers, json=payload
    )
    print(f"POST /me/accept-caregiver-request (Family Member): {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
    else:
        print(f"Error: {response.text}")

    # Test rejecting a request
    payload = {"request_id": 3}
    response = requests.post(
        f"{BASE_URL}/me/reject-caregiver-request", headers=headers, json=payload
    )
    print(f"POST /me/reject-caregiver-request (Family Member): {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
    else:
        print(f"Error: {response.text}")

    # Test for senior citizen
    headers = {"Authorization": f"Bearer {SENIOR_CITIZEN_TOKEN}"}

    # Test accepting a request
    payload = {"request_id": 1}
    response = requests.post(
        f"{BASE_URL}/me/accept-caregiver-request", headers=headers, json=payload
    )
    print(f"POST /me/accept-caregiver-request (Senior Citizen): {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
    else:
        print(f"Error: {response.text}")


def test_current_caregiver():
    """Test getting current caregiver for both roles."""
    print("\nTesting current caregiver retrieval...")

    # Test for family member
    headers = {"Authorization": f"Bearer {FAMILY_TOKEN}"}
    response = requests.get(f"{BASE_URL}/me/current-caregiver", headers=headers)
    print(f"GET /me/current-caregiver (Family Member): {response.status_code}")
    if response.status_code in [200, 404]:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
    else:
        print(f"Error: {response.text}")

    # Test for senior citizen
    headers = {"Authorization": f"Bearer {SENIOR_CITIZEN_TOKEN}"}
    response = requests.get(f"{BASE_URL}/me/current-caregiver", headers=headers)
    print(f"GET /me/current-caregiver (Senior Citizen): {response.status_code}")
    if response.status_code in [200, 404]:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
    else:
        print(f"Error: {response.text}")


if __name__ == "__main__":
    print("Testing Caregiver Request Functionality")
    print("=" * 50)

    test_caregiver_requests_family_member()
    test_caregiver_requests_senior_citizen()
    test_accept_reject_caregiver_requests()
    test_current_caregiver()

    print("\nTest completed!")
