var google_map = null;
var google_init = false;
var google_overlays = null;
var google_bounds = new GLatLngBounds();
var google_defaultZoom = 15;

function Google_Load()
{
    $(document).observe('readystatechange', function(){
       if ((document.readyState == "complete") && (google_map != null))
       {
           google_map.checkResize();
           Google_ShowAllMarkers();
       }
    });
}

function Google_Unload()
{
    GUnload();
}

function Google_FocusMarker(pos, marker_info_html)
{
    google_map.openInfoWindowHtml(pos, marker_info_html, { pixelOffset: new GSize(5,-30) } );
}

function Google_CreateMarker(lat, lng, marker_url, marker_info_html)
{
    Google_Load();
    
    var marker = null;
    var pos = new GLatLng(lat, lng);

    var icon = new GIcon();

    icon.image = marker_url;
    icon.iconSize = new GSize(40,40);
    icon.iconAnchor = new GPoint(12,38);

    marker = new GMarker(pos, icon);

    if ((marker_info_html != null) && (marker_info_html.length > 0))
    {
        GEvent.addListener(marker, 'mouseover', function() {
            Google_FocusMarker(pos, marker_info_html);
        });
    }
    
    google_bounds.extend(pos);

    return marker;
}

function Google_ShowAllMarkers()
{
    google_map.closeInfoWindow();
    google_map.checkResize();
    zoom = google_map.getBoundsZoomLevel(google_bounds);
    if (zoom > google_defaultZoom) zoom = google_defaultZoom;
    google_map.setZoom(zoom);
    google_map.setCenter(google_bounds.getCenter());

}

function Google_ProcessOverlays()
{
    if ((google_overlays != null) && (google_init  == true))
    {
        if (google_map != null)
        {
            while (google_overlays.length > 0)
            {
                google_map.addOverlay(google_overlays.pop());
            }
        }

        google_overlays = null;
        Google_ShowAllMarkers();
    }
}

function Google_InitMap(map_id, lat, lng)
{
    Google_Load();

    google_init = true;

    if (GBrowserIsCompatible())
    {
        google_map = new GMap2($(map_id));
	google_map.disableScrollWheelZoom();
        google_map.addControl(new GSmallMapControl());
        google_map.setCenter(new GLatLng(lat, lng), google_defaultZoom);

        GEvent.addListener(
            google_map,
            'infowindowclose',
            function()
            {
                Google_ShowAllMarkers();
                //google_map.setCenter(new GLatLng(lat, lng));
            }
        );

        Google_ProcessOverlays();
    }

}

function Google_AddMarker(lat, lng, marker_url, marker_info_html, link_element)
{
    if (google_overlays == null)
    {
        google_overlays = new Array();
    }

    var marker = Google_CreateMarker(lat, lng, marker_url, marker_info_html);

    google_overlays.push(marker);

    Google_ProcessOverlays();

    if (link_element != null)
    {
        elem = $(link_element)
        elem.observe('mouseover', function(){
            Google_FocusMarker(marker.getLatLng(), marker_info_html);
        });
        elem.observe('mouseout', function(){
            Google_ShowAllMarkers();

        });

    }

    return marker;
}

function Google_ClearMarkers()
{
    if (google_map != null)
    {
        google_map.clearOverlays();
    }
}

