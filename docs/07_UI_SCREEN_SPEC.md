# 07. UI Screen Specification

## Visual Direction

Use the provided design draft as structure reference, but actual illustrations should use company-provided hand-made touch illustrations when available.
Do not use random internet images.

## Common UI

- Rounded cards
- Friendly elementary-student tone
- Large tappable buttons
- Clear feedback
- Minimal text density
- Strong fallback when assets are missing

## Screens

### S-01 Splash

Elements:

- App logo/name
- Short loading state

Behavior:

- First MVP: 1 second delay → `/login`
- Later: session exists → `/home`

### S-02 Login

Elements:

- School search input
- Search button
- Search results
- Selected school card
- Name input
- Grade chips: 3/4/5/6
- Start button

Validation:

- Search keyword >= 2 chars
- School selected
- Name not empty
- Grade selected

### S-03 Home

Elements:

- Character image
- Greeting
- Level and XP bar
- Today's mission card
- Today's Hanja progress N/5
- Quiz card
- Game card
- Growth button

### S-04 Hanja Card

Elements:

- Unit title
- Large Hanja
- sound/meaning/stroke count
- Image card
- Example sentence
- Stroke preview
- Writing
- Quiz
- Prev/Next

### S-05 Writing

Elements:

- Back/close
- guide character
- stroke/drawing canvas
- accuracy
- speed optional
- retry
- complete

### S-06 Quiz

Elements:

- N/10
- timer optional
- prompt
- 4 options
- feedback
- next

### S-07 Result

Elements:

- congratulatory message
- stars
- character
- XP/coins
- accuracy
- correct count
- retry
- next/home

### S-08 Game

Elements:

- meaning prompt
- Hanja options 4~6
- time gauge
- score
- combo

### S-10 Growth

Elements:

- character
- level
- XP bar
- badges
- ability bars

### T-01 Teacher Preview

Elements:

- class name
- student count
- assignment summary
- student result table

Must not implement real assignment creation in MVP.
