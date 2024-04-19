# EssentialApp
Essential App case study

![CI](https://github.com/D-Link13/EssentialApp/actions/workflows/CI-macOS.yml/badge.svg)


// *** BDD Stories *** //


// Narrative #1

    As an online customer
    I want my app to automaticaly load my latest image feed
    So I can enjoy the newest images of my friends

- Scenarios (Acceptance criteria)

    Given the customer has connectivity
    When the customer requests to see the feed
    Then the app should display the latest feed from remote
    And replace the cache with the new feed

// Narrative #2

    As an offline customer
    I want my app to show the latest saved version of my image feed
    So I can always enjoy images of my friends

- Scenarios (Acceptance criteria)

    Given the customer has no connectivity
    And there's a cached version of the feed
    When the customer requests to see the feed
    Then the app should display the latest feed saved

    Given the customer has no connectivity
    And the cache is empty
    When the customer requests to see the feed
    Then the app should display an error message




// *** Use Cases *** //


// Load Feed Use Case

- Data(Input)
    * URL

- Primary course (Happy path):

    1. Execute "Load Feed Items" command with above data.
    2. System downloads data from the URL.
    3. System validates downloaded data.
    4. System creates feed items from valid data.
    5. System delivers feed items.
    
- Invalid data (Sad path):

    1. System delivers error.
    
- No connectivity (Sad path):

    1. System delivers error.
    
    
// Load Feed Fallback (Cache) Use Case

- Data(Input)
    * Max age

- Primary course (Happy path):

    1. Execute "Retrieve Feed Items" command with above data.
    2. System fetches feed data from cache.
    4. System creates feed items from cached data.
    5. System delivers feed items.
    
- No cache course (Sad path):

    1. System delivers no feed items.
    
    
// Save Feed Use Case

- Data(Input)
    * Feed Items
    
- Primary course (Happy path):

    1. Execute "Save Feed Items" command with above data.
    2. System encodes feed items.
    3. System timestamps the new cache.
    4. System replaces the old cache with new data.
    5. System delivers a success message.
