return {
    {
        "chrisgrieser/nvim-early-retirement",
        event = {
            "User IceLoad",
        },
        opts = {
            -- If a buffer has been inactive for this many minutes, close it.
            retirementAgeMins = 5,
        },
    },
}
