
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
    
    // no iPhone
    if(navigator.appVersion.indexOf('iPhone OS ') < 0)
    {
        document.getElementById("noiphone").style.visibility = "visible";
    }
    else if(!window.navigator.standalone)
    {
        document.getElementById("notinstalled").style.visibility = "visible";
    }
    else if(!hasNavigation())
    {
        document.getElementById("nonavigation").style.visibility = "visible";
    }
    else
    {
        // we're on a phone, and installed standalone
        // "real" app init code goes here
        document.getElementById("navigation").style.visibility = "visible";
        
        navigator.geolocation.watchPosition(positionWatcher);
    }
}
