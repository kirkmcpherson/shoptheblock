
var NEWS_LENGTH = 5

function Application_Load(app_root)
{
}

function Application_Unload()
{
}

function rotateNews()
{
  news_items = news_div.select('div.news_item');
  news_items[NEWS_LENGTH-1].style.display="none";
  news_items.last().style.display="";
  news_div.insertBefore(news_items.last(),news_items.first());
}

function rotateTestimonials()
{
  testimonials = testimonials_div.select('div.testimonial');
  testimonials[NEWS_LENGTH-1].style.display="none";
  testimonials.last().style.display="";
  testimonials_div.insertBefore(testimonials.last(), testimonials.first());
}

Event.observe(window, 'load', function()
{
  news_div = $('news');
  if ($$('div.news_item').length > NEWS_LENGTH) {
    setInterval("rotateNews();", 5000);
  }
  testimonials_div = $('testimonials');
  if ($$('div.testimonial').length > NEWS_LENGTH) {
    setInterval("rotateTestimonials();", 5000);
  }
});

function setTabIndex()
{
  $$(".mceToolbar a").invoke("setAttribute", "tabIndex", "-1");
}

var DateShippedHandler = Behavior.create({
  onclick : function(e) {
    var id = this.element.id.split(/_/)[1];
    var datebox = $('ship_date_' + id);
    var d = new Date();
    var today_str = (d.getMonth() + 1) + '/' + d.getDate() + '/' + d.getFullYear();
    (this.element.checked === true) ? datebox.value = today_str : datebox.value = '';
  }
});
Event.addBehavior({ '.shipped_box': DateShippedHandler });
Event.addBehavior.reassignAfterAjax = true;


function lastNewsletterItemPositionField()
{
      return $$('div.newsletter_item_container:last-child input.position').first();
}

function moveNewsletterItem(element, direction)
{
  var sibling = null;

  if (direction == 'up') { sibling = element.previous('div'); }
  else { sibling = element.next('div'); }

  if (!sibling) { return false; }

  if (direction == 'up') { swapElements(element, sibling); }
  else { swapElements(sibling, element); }

  var siblingPosition = sibling.down('input.position').value;
  sibling.down('input.position').value = element.down('input.position').value;
  element.down('input.position').value = siblingPosition;

  disableMoveNewsletterItemLinks();

  return true;
}

function swapElements(first, second)
{
  // moving dom elements around tends to kill tiny mce
  // so we have to remove it first then add it back after
  var mceEditor = first.down('textarea.mceEditor');
  if (mceEditor) { tinyMCE.execCommand('mceRemoveControl', false, mceEditor.id); }
  first.up(0).insertBefore(first, second);
  if (mceEditor) { tinyMCE.execCommand('mceAddControl', false, mceEditor.id); }
}

function disableMoveNewsletterItemLinks()
{
  $$('a.newsletter_item_link').invoke('removeClassName', 'disabled');
  $$('a.newsletter_item_link.move_up').first().addClassName('disabled');
  $$('a.newsletter_item_link.move_down').last().addClassName('disabled');
}

function setChecked(className, checked)
{
  $$('input[type=checkbox].' + className).each(function(checkbox)
  {
    checkbox.checked = checked;
  });
}

function compare_emails()
{
    var form = $('form_signup');
    if ( form  == null )
       return;

    var input_confirm = form['user_confirm_email'];
    var input_email   = form['user_email'];
    var enable = true;

    if( $F(input_confirm) != $F(input_email) )
     {
       $("email_error").show();
       enable = false;
     }
     else
     {
       $("email_error").hide();
     }
     // if user has different emails , try to disable submit buttons
     var elements =  $("submit_buttons").childNodes;

     for( var i=0; i < elements.length; i++)
     {
          if(  elements[i].name == "commit" )
             enable == false ? elements[i].disable() : elements[i].enable();

     }
}

function doSearch(page)
{
  //  alert("search");
   $('pageIndex').value = page;
   $('search_button').click();
}

function setError(txt)
{
    var error = $('searchError');
    error.update(txt);
    error.show();
}

function validateFailed(request)
{
    setError('Invalid address');
}
// the script from partial 'home/search' , it starts a search
function validateSucceeded(request)
{
    var error = $('searchError');
    error.hide();
    $('searchForm').submit();
}

// whole credits are devoted to orignal author
//
// Use: Call function goto_top()
// source:  http://www.xfunda.com/index.php?
// option=com_content&view=article&id=55:javascript-page-scroll-scroll-a-web-page-from-bottom-to-top-smoothly&catid=40:javascript&Itemid=75
var goto_top_type = -1;
var goto_top_itv = 0;
var top_element = 0
function goto_top_timer(id)
{

    var y = goto_top_type == 1  ? document.documentElement.scrollTop : document.body.scrollTop;

   // scroll top the concreate element for example 'search_reasults''
  // alert(y);
    if(    top_element  != 0 &&  y < top_element  )
   {
            clearInterval(goto_top_itv);
             goto_top_itv = 0;
       return;
  }
     
    var moveby = 25; // set this to control scroll seed. minimum is fast

    y -= Math.ceil(y * moveby / 100);
    if (y < 0)
        y = 0;

    if (goto_top_type == 1)
        document.documentElement.scrollTop = y;
    else
        document.body.scrollTop = y;

    if (y == 0) {
        clearInterval(goto_top_itv);
        goto_top_itv = 0;
    }
}
function Top(obj)
{
        var curtop = 0;

        if (obj.offsetParent)
            while (1)
            {
                curtop += obj.offsetTop;
                if (!obj.offsetParent)
                break;
                obj = obj.offsetParent;
            }
        else if ( obj.y )
            curtop += obj.y;

        return curtop;
}

function goto_top( id )
{
    if (goto_top_itv == 0)
    {
        if (document.documentElement && document.documentElement.scrollTop)
            goto_top_type = 1;
        else if (document.body && document.body.scrollTop)
            goto_top_type = 2;
        else
            goto_top_type = 0;


        if( id != null  &&  document.getElementById(id) )       
             top_element = Top(document.getElementById(id)) ;                 
        
          
        if (goto_top_type > 0)
            goto_top_itv = setInterval('goto_top_timer()', 25);
    }
}


function switchTabs(tab, value)
{

        $A($('Tabs').getElementsByClassName('Tab')).each(function(child)
        {

        if (child == tab)
        {
            child.addClassName('active');
        }
        else
        {
            child.removeClassName('active');
        }
        });


        if (value != null)
        {        
           $('typeTab').setValue(value);
           $('change').click();
        }
}

  function searchTabs_setActive(tab, value)
  {
     $A($('searchTabs').getElementsByClassName('searchTab')).each(function(child)
     {
        if (child == tab)
        {
            child.addClassName('active');
        }
        else
        {
           child.removeClassName('active');
        }
      });
      if (value != null)
      {
        $('search_type').setValue(value);
                   
        $('search_button').click();
      }

  }

// function for store/_edit_hours_item ( check box  : onclick )
function enable_store_hours ( enable  , select_tag_id )
{
            if( enable == true )
            {                
                $('start_hour'  + select_tag_id ).enable();
                $( 'end_hour' +  select_tag_id ).enable();
                $( 'start_minute' +  select_tag_id).enable();
                $( 'end_minute' +  select_tag_id).enable();
            }
            else
            {
                $('start_hour'  + select_tag_id ).disable();
                $( 'end_hour' +  select_tag_id ).disable();
                $( 'start_minute' +  select_tag_id).disable();
                $( 'end_minute' +  select_tag_id).disable();
         
            }
}
