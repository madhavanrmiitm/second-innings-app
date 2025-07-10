import re
from typing import Dict, Optional
from urllib.parse import parse_qs, urlparse

from app.config import settings
from app.logger import logger
from google import genai


class YouTubeProcessor:
    def __init__(self):
        """Initialize YouTube processor with Gemini AI client."""
        try:
            self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
            logger.info("YouTube processor initialized with Gemini AI")
        except Exception as e:
            logger.error(f"Failed to initialize YouTube processor: {e}")
            raise

    def extract_video_id(self, youtube_url: str) -> Optional[str]:
        """
        Extract video ID from various YouTube URL formats.

        Args:
            youtube_url: YouTube URL in various formats

        Returns:
            Video ID if found, None otherwise
        """
        try:
            # Handle different YouTube URL formats
            patterns = [
                r"(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})",
                r"youtube\.com\/.*[?&]v=([a-zA-Z0-9_-]{11})",
            ]

            for pattern in patterns:
                match = re.search(pattern, youtube_url)
                if match:
                    return match.group(1)

            # Fallback: try to parse as query parameter
            parsed_url = urlparse(youtube_url)
            if parsed_url.hostname in ["youtube.com", "www.youtube.com"]:
                query_params = parse_qs(parsed_url.query)
                if "v" in query_params:
                    return query_params["v"][0]

            logger.warning(f"Could not extract video ID from URL: {youtube_url}")
            return None

        except Exception as e:
            logger.error(f"Error extracting video ID from URL {youtube_url}: {e}")
            return None

    def generate_caregiver_analysis(
        self, youtube_url: str, full_name: str
    ) -> Dict[str, str]:
        """
        Analyze YouTube video and generate tags and description for caregiver.

        Args:
            youtube_url: YouTube video URL
            full_name: Caregiver's full name

        Returns:
            Dictionary with 'tags' and 'description' keys
        """
        try:
            video_id = self.extract_video_id(youtube_url)
            if not video_id:
                raise ValueError("Invalid YouTube URL format")

            # Construct the prompt for Gemini AI
            prompt = f"""
            Analyze this YouTube video URL: {youtube_url}

            This is a caregiver who is registering on a platform called "Second Innings"
            which focuses on hiring caregivers for senior citizens.

            Based on the video content, please provide:

            1. TAGS: Generate 4-6 relevant tags separated by commas. Focus on:
               - Care/support abilities (rehabilitation, fitness, mentoring, etc.)
               - Personal qualities (patient, experienced, enthusiastic, etc.)
               - Location (if mentioned)

            2. DESCRIPTION: Write a 200 word professional description of this caregiver
               highlighting their expertise, experience, and what makes them suitable for
               helping senior citizens.

            Format your response exactly like this:
            TAGS: tag1, tag2, tag3, tag4, tag5
            DESCRIPTION: Professional description here.

            If you cannot access the video content, generate appropriate caregiving
            tags and description based on the fact they submitted a YouTube video for caregiver registration.
            """

            # Call Gemini AI
            response = self.client.models.generate_content(
                model="gemini-2.5-flash", contents=prompt
            )

            print(response.text)

            return self._parse_ai_response(response.text, full_name)

        except Exception as e:
            logger.error(f"Error analyzing YouTube video {youtube_url}: {e}")
            # Return fallback content
            return self._generate_fallback_content(full_name)

    def generate_interest_group_admin_analysis(
        self, youtube_url: str, full_name: str
    ) -> Dict[str, str]:
        """
        Analyze YouTube video and generate tags and description for interest group admin.

        Args:
            youtube_url: YouTube video URL
            full_name: Interest group admin's full name

        Returns:
            Dictionary with 'tags' and 'description' keys
        """
        try:
            video_id = self.extract_video_id(youtube_url)
            if not video_id:
                raise ValueError("Invalid YouTube URL format")

            # Construct the prompt for Gemini AI
            prompt = f"""
            Analyze this YouTube video URL: {youtube_url}

            This is an interest group admin who is registering on a platform called "Second Innings"
            which focuses on organizing activities and interest groups for senior citizens.

            Based on the video content, please provide:

            1. TAGS: Generate 4-6 relevant tags separated by commas. Focus on:
               - Activity/interest areas (arts, crafts, music, sports, reading, gardening, etc.)
               - Leadership qualities (organized, enthusiastic, communicative, etc.)
               - Group management skills (event planning, coordination, mentoring, etc.)
               - Location (if mentioned)

            2. DESCRIPTION: Write a 200 word professional description of this interest group admin
               highlighting their expertise, experience, and what makes them suitable for
               organizing and managing interest groups for senior citizens.

            Format your response exactly like this:
            TAGS: tag1, tag2, tag3, tag4, tag5
            DESCRIPTION: Professional description here.

            If you cannot access the video content, generate appropriate interest group management
            tags and description based on the fact they submitted a YouTube video for interest group admin registration.
            """

            # Call Gemini AI
            response = self.client.models.generate_content(
                model="gemini-2.5-flash", contents=prompt
            )

            print(response.text)

            return self._parse_ai_response(response.text, full_name)

        except Exception as e:
            logger.error(f"Error analyzing YouTube video {youtube_url}: {e}")
            # Return fallback content
            return self._generate_fallback_content_interest_group(full_name)

    def _parse_ai_response(self, response_text: str, full_name: str) -> Dict[str, str]:
        """
        Parse the AI response to extract tags and description.

        Args:
            response_text: Raw response from Gemini AI
            full_name: Caregiver's name for fallback

        Returns:
            Dictionary with parsed tags and description
        """
        try:
            # Extract tags and description from response
            tags_match = re.search(r"TAGS:\s*(.+)", response_text, re.IGNORECASE)
            description_match = re.search(
                r"DESCRIPTION:\s*(.+)", response_text, re.IGNORECASE | re.DOTALL
            )

            tags = tags_match.group(1).strip() if tags_match else None
            description = (
                description_match.group(1).strip() if description_match else None
            )

            # Clean up the extracted content
            if tags:
                # Remove any extra formatting, keep only the tags
                tags = re.sub(r"\n.*", "", tags).strip()
                # Ensure proper comma separation
                tags = ", ".join(
                    [tag.strip() for tag in tags.split(",") if tag.strip()]
                )

            if description:
                # Clean up description, take first few sentences
                description = re.sub(r"\n+", " ", description).strip()
                sentences = description.split(".")
                if len(sentences) > 3:
                    description = ". ".join(sentences[:3]) + "."

            # Validate and return results
            result = {
                "tags": tags or self._generate_fallback_content(full_name)["tags"],
                "description": description
                or self._generate_fallback_content(full_name)["description"],
            }

            logger.info(f"Successfully generated tags and description for {full_name}")
            return result

        except Exception as e:
            logger.error(f"Error parsing AI response: {e}")
            return self._generate_fallback_content(full_name)

    def _generate_fallback_content(self, full_name: str) -> Dict[str, str]:
        """
        Generate fallback tags and description when AI analysis fails.

        Args:
            full_name: Caregiver's name

        Returns:
            Dictionary with fallback tags and description
        """

        return {
            "tags": "none",
            "description": "Failed to generate tags and description for "
            + full_name
            + " either because the video is not available or the AI failed to generate the tags and description for the video.",
        }

    def _generate_fallback_content_interest_group(
        self, full_name: str
    ) -> Dict[str, str]:
        """
        Generate fallback tags and description when AI analysis fails for interest group admin.

        Args:
            full_name: Interest group admin's name

        Returns:
            Dictionary with fallback tags and description
        """

        return {
            "tags": "none",
            "description": "Failed to generate tags and description for "
            + full_name
            + " either because the video is not available or the AI failed to generate the tags and description for the video.",
        }


# Singleton instance
youtube_processor = YouTubeProcessor()
