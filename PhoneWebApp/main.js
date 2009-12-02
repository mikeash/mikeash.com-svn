
function hasNavigation()
{
    return (typeof navigator.geolocation != "undefined");
}

function positionWatcher(location)
{
    document.getElementById("longitude").firstChild.nodeValue = location.coords.longitude;
    document.getElementById("latitude").firstChild.nodeValue = location.coords.latitude;
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
