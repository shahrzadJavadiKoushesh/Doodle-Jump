# Doodle Jump

This repository is for microprocessor's mini-project. It is a simplified version of doodle jump. You can play it online [here](https://doodlejump.io/).

## Installation

First, you need to download [DosBox](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqbExvZmJjeTJCNWFTdG90d3JFdzlnUEpmRlZtUXxBQ3Jtc0tsc2JlTDNVcml3S3Zkdm5fSXlxQkRDNXp0ZlVQQVdWa0h1aHNtYzdTWTl1MDJWY2dDcXoyamtVRG04TXhVN1EwVHdQSE04LUI0Q2tlQmhnclE0M28tOTdCVmVfemw0QlROWmFUWG54MHl2Tk94VERMRQ&q=https%3A%2F%2Fwww.dosbox.com%2Fdownload.php%3Fmain%3D1&v=RhsaakpatqI) and [8086 assembler](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqa1o4Ulg4ZllWQ0JiSjNldnZuN1JzS1hlVzdvUXxBQ3Jtc0tsdUZsQjF1ZGJ0bVN2RmdpWlAxZDRqM1g4MUZtSlBmdkVRX0pDNXFZdjJjN3NBU3E2MlVKdmZSNUFqYjBXMFpob1ZxY29heFB3V2RJMlRyeF9WS0Q5TjhHcjRJNUtzMjItQkdVZGdPSEtVUWc5Y2dQZw&q=https%3A%2F%2Fdrive.google.com%2Fopen%3Fid%3D1akM4UNg6StiVE3ehzEstOgOhEw1JBxA0&v=RhsaakpatqI). 
In order to run the program:

```bash
masm /a test.asm
link test
test
```
In this game, there are two enemies which are red and the player loses 2 points if the ball is collided with them. The location of the paddle changes every time the ball is collided with it randomly. If the ball reaches the ground, the game is over immediately.

