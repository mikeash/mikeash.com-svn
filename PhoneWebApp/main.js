
function hasNavigation()
{
    return (typeof navigator.geolocation != "undefined");
}

function positionWatcher(location)
{
    document.getElementById("longitude").textContent = location.coords.longitude;
    document.getElementById("latitude").textContent = location.coords.latitude;
}

function load()
{
    document.getElementById("loading").style.visibility = "hidden";
    
    if(!hasNavigation())
    {
        document.getElementById("nonavigation").style.visibility = "visible";
    }
    else
    {
        document.getElementById("navigation").style.visibility = "visible";
        
        navigator.geolocation.watchPosition(positionWatcher);
    }
}
