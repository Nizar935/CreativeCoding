// -- Global variables ...
String[] lightData;
String[][] data; // First dimension is row, second is column
float lightSize = 40; // Determines sizes of circles
float[][] circleX; // Stores the x positions and directions for each light
float[] speeds; // Stores the speeds based on hours spent outside

import processing.sound.*;

SoundFile lowHoursSound;
SoundFile mediumHoursSound;
SoundFile highHoursSound;

void setup() {
    size(900, 900);
    textAlign(CENTER, CENTER);
    textSize(18);
    ellipseMode(CENTER);

    lightData = loadStrings("Data for CC.csv");

    // Initialize the data array
    data = new String[lightData.length][];
    for (int i = 0; i < lightData.length; i++) {
        String[] dataItems = split(lightData[i], ",");
        data[i] = new String[dataItems.length];
        for (int d = 0; d < dataItems.length; d++) {
            data[i][d] = dataItems[d];
        }
    }

    // Initialize circle positions and speeds
    circleX = new float[data.length][];
    speeds = new float[data.length];
    for (int i = 0; i < data.length; i++) {
        circleX[i] = new float[data[i].length];
        for (int d = 0; d < data[i].length; d++) {
            circleX[i][d] = lightSize * 3 + d * lightSize * 1.5; // Initial positions
        }
        speeds[i] = random(2, 5); // Random speed for each row
    }

    // Load sound files
    lowHoursSound = new SoundFile(this, "lowHoursSound.wav");
    mediumHoursSound = new SoundFile(this, "mediumHoursSound.wav");
    highHoursSound = new SoundFile(this, "highHoursSound.wav");
}

void draw() {
    background(250);

    for (int i = 0; i < data.length; i++) {
        float y = lightSize + i * lightSize * 1.5; // Row positions
        String dayName = data[i][0];
        fill(32, 128);
        text(dayName, lightSize * 1.5, y); // Day names

        for (int d = 1; d < data[i].length; d++) {
            float x = circleX[i][d];
            boolean weHaveData = true;
            String light = data[i][d];
            color fillColour = color(255);

            if (d == 1) {
                // Second column: Display "yes" or "no"
                fillColour = light.equalsIgnoreCase("yes") ? color(32, 200, 32) : color(240, 64, 64);
            }

            if (d == 2) {
                // Third column: Handle hours spent outside
                float hours = 0;
                try {
                    hours = Float.parseFloat(light.trim());
                } catch (NumberFormatException e) {
                    weHaveData = false; // Invalid data
                }

                if (weHaveData) {
                    if (hours == 0) {
                        fillColour = color(240, 64, 64); // Red for 0 hours
                    } else if (hours > 0 && hours <= 2) {
                        fillColour = color(255, 165, 0); // Orange for 1-2 hours
                    } else if (hours > 2 && hours <= 4) {
                        fillColour = color(32, 200, 32); // Green for 3-4 hours
                    } else if (hours > 4) {
                        fillColour = color(64, 64, 240); // Blue for >4 hours
                    }

                    // Update position and check for bounce (only if hours > 0)
                    if (hours > 0) {
                        circleX[i][d] += speeds[i];
                        if (circleX[i][d] > width - lightSize || circleX[i][d] < lightSize * 2) {
                            speeds[i] *= -1; // Reverse direction
                            playBounceSound(hours); // Play sound
                        }
                    } else {
                        // Keep the circle static for 0 hours
                        circleX[i][d] = lightSize * 3 + d * lightSize * 1.5;
                    }
                }
            }

            // Draw circle
            if (weHaveData) {
                noStroke();
                fill(fillColour);
                circle(circleX[i][d], y, lightSize * 0.8);

                // Add "yes"/"no" inside circles for the second column
                if (d == 1) {
                    fill(0); // Black text
                    text(light, circleX[i][d], y); // "yes" or "no"
                }
            }
        }
    }
}

// Function to play the correct sound on bounce
void playBounceSound(float hours) {
    if (hours > 0 && hours <= 2) {
        lowHoursSound.play(); // Low hours
    } else if (hours > 2 && hours <= 4) {
        mediumHoursSound.play(); // Medium hours
    } else if (hours > 4) {
        highHoursSound.play(); // High hours
    }
}

void mouseMoved() {
    loop();
}
void keyPressed() {
    if (key == '>') {
        lightSize = lightSize * 1.1;
    }
    if (key == '<') {
        lightSize = lightSize / 1.1;
    }
    loop();
}
