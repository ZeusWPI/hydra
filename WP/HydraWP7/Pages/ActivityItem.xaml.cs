using System;
using System.Collections.Generic;
using System.Device.Location;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;
using Facebook;
using HydraWP7.Data;
using Microsoft.Phone.Tasks;

namespace HydraWP7.Pages
{
    public partial class ActivityItem
    {
        private ActivityItemsViewModel _item;
        public ActivityItem()
        {
            InitializeComponent();
        }

        // Load data for the ViewModel NewsItems
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            try
            {
                _item = App.ViewModel.ActivityItems.ElementAt(Convert.ToInt32(NavigationContext.QueryString["activityItem"]));
                if (_item == null)
                {
                    throw new Exception("Er is geen activiteit mee gegeven als argument.");
                }
                if (_item.FacebookId == null || _item.FacebookId.Equals("") || !App.ViewModel.HasConnection)
                {
                   DataContext = _item;
                    return;
                }
                _item.RsvpStatus = GetRsvp(_item);
                _item.FriendsPics = FriendImages(_item);
                var fb = new FacebookClient
                {
                    AppId = App.ViewModel.Appid,
                    AccessToken = App.ViewModel.UserPreference.AccessKey ??
                                  App.ViewModel.GenericId
                };

                fb.GetCompleted += (o, res) =>
                {
                    if (res.Error != null)
                    {
                        return;
                    }

                    var result = (IDictionary<string, object>)res.GetResultData();
                    var data = (IList<object>)result["data"];
                    var eventData = ((IDictionary<string, object>)data.ElementAt(0));
                    
                    _item.Attendings = Convert.ToInt32(eventData["attending_count"]);
                    _item.ImageUri = (string)eventData["pic"];

                    Dispatcher.BeginInvoke(()=>DataContext = _item);
                };

                // query to get all the friends
                var query = string.Format("SELECT eid,attending_count, pic FROM event WHERE eid = {0}", _item.FacebookId);


                // Note: For windows phone 7, make sure to add [assembly: InternalsVisibleTo("Facebook")] if you are using anonymous objects as parameter.
                fb.GetAsync("fql", new { q = query });
            }
            catch (Exception)
            {
                NavigationService.Navigate(new Uri("/Pages/MainPage.xaml", UriKind.Relative));
            }

        }

        private void LocationHandler(object sender, System.Windows.Input.GestureEventArgs e)
        {
            new BingMapsDirectionsTask { End = new LabeledMapLocation(_item.Location, new GeoCoordinate(_item.Latitude, _item.Longitude)) }.Show();
        }


        private void ButtonsOnClick(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            if (button != null) SetRsvp(button.Name, (ActivityItemsViewModel)DataContext);
            if (button != null && button.Name.Equals("attending"))
            {
                attending.IsEnabled = false;
                declined.IsEnabled = true;
                maybe.IsEnabled = true;
            }
            else if (button != null && button.Name.Equals("maybe"))
            {
                attending.IsEnabled = true;
                declined.IsEnabled = true;
                maybe.IsEnabled = false;
            }
            else if (button != null && button.Name.Equals("declined"))
            {
                attending.IsEnabled = true;
                declined.IsEnabled = false;
                maybe.IsEnabled = true;
            }
        }

        public List<string> FriendImages(ActivityItemsViewModel act)
        {
            if (App.ViewModel.UserPreference.AccessKey == null || act.FacebookId == null || act.FacebookId.Equals("") || !App.ViewModel.HasConnection)
                return null;
            var friends = new List<string>();
            var fb = new FacebookClient
            {
                AppId = App.ViewModel.Appid,
                AccessToken = App.ViewModel.UserPreference.AccessKey
            };
            fb.GetCompleted += (o, e) =>
            {
                if (e.Error != null)
                {
                    return;
                }
                var result = (IDictionary<string, object>)e.GetResultData();
                var data = (IList<object>)result["data"];
                if (data.Count <= 0)
                {
                    return;
                }
                act.FriendsAttending = data.Count;
                for (var i = 0; i < 5; i++)
                {
                    var eventData = ((IDictionary<string, object>)data.ElementAt(i));
                    friends.Add((string)eventData["pic_square"]);
                }


            };
            var query = String.Format("SELECT pic_square FROM user WHERE uid IN"
            + "(SELECT uid2 FROM friend WHERE uid1 = me() AND uid2 IN"
            + "(SELECT uid FROM event_member WHERE eid = {0} "
            + "AND rsvp_status = 'attending'))", act.FacebookId);
             fb.GetAsync("fql", new { q = query });
            return friends;
        }

        public string GetRsvp(ActivityItemsViewModel act)
        {
            if (App.ViewModel.UserPreference.AccessKey == null || act.FacebookId == null || act.FacebookId.Equals("") || !App.ViewModel.HasConnection)
                return null;
            string status = null;
            var fb = new FacebookClient
            {
                AppId = App.ViewModel.Appid,
                AccessToken = App.ViewModel.UserPreference.AccessKey
            };
            fb.GetCompleted += (o, e) =>
            {
                if (e.Error != null)
                {
                    return;
                }
                var result = (IDictionary<string, object>)e.GetResultData();
                var data = (IList<object>)result["data"];
                if (data.Count <= 0)
                {
                    status = "not_replied";
                    return;
                }
                var eventData = ((IDictionary<string, object>)data.ElementAt(0));
                status = (string)eventData["rsvp_status"];

            };
            var query = String.Format("SELECT rsvp_status FROM event_member  WHERE eid = {0} AND uid = me()", act.FacebookId);
            fb.GetAsync("fql", new { q = query });
            return status;
        }





        public void SetRsvp(string name, ActivityItemsViewModel act)
        {
            if (App.ViewModel.UserPreference.AccessKey == null || act.FacebookId == null || act.FacebookId.Equals("") || !App.ViewModel.HasConnection)
                return;
            var fb = new FacebookClient { AccessToken = App.ViewModel.UserPreference.AccessKey, AppId = App.ViewModel.Appid };
            fb.GetCompleted += (o, e) =>
            {
                if (e.Error != null)
                {
                    Deployment.Current.Dispatcher.BeginInvoke(
                        () => MessageBox.Show(
                            "Er gebeurde een fout tijdens het versturen van data naar Facebook"));
                }
                act.RsvpStatus = GetRsvp(act).ToString();


            };
            var query = string.Format("https://graph.facebook.com/{0}/{1}", act.FacebookId, name);
            fb.PostAsync(query, null);
        }
    }
}