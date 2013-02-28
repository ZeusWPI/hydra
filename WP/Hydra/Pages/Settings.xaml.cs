using System;
using System.Collections.Generic;
using System.Globalization;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;
using Facebook;
using Hydra.Data;

namespace Hydra.Pages
{
    public partial class Settings
    {
        public Settings()
        {
            InitializeComponent();
            var dataSource = AssociationList<Association>.CreateGroups(App.ViewModel.Associtions,
                                                                       new CultureInfo("nl-BE"), s => s.Dn, true);
            associations.ItemsSource = dataSource;
            DataContext = App.ViewModel.UserPreference;

        }


        protected override void OnNavigatingFrom(NavigatingCancelEventArgs e)
        {
            App.ViewModel.SaveSettings();
            base.OnNavigatingFrom(e);
        }

        private void ToggleSwitch_OnChecked(object sender, RoutedEventArgs e)
        {
            toggleSwitch.Content = "Aan";
            App.ViewModel.UserPreference.IsFiltering = true;
        }

        private void ToggleSwitchUnChecked(object sender, RoutedEventArgs e)
        {
            toggleSwitch.Content = "Uit";
            App.ViewModel.UserPreference.IsFiltering = false;
        }


        private void AssociationAdded(object sender, SelectionChangedEventArgs e)
        {
            var item = e.AddedItems[0] as Association;
            if (item != null && !App.ViewModel.UserPreference.PreferredAssociations.Contains(item))
                App.ViewModel.UserPreference.PreferredAssociations.Add(item);
            else if (item != null && App.ViewModel.UserPreference.PreferredAssociations.Contains(item))
            {
                App.ViewModel.UserPreference.PreferredAssociations.Remove(item);
            }
        }



        private void FaceBookLoginPageNavigated(object sender, NavigationEventArgs e)
        {
            if (FaceBookLoginPage.Visibility == Visibility.Collapsed)
                return;
            FacebookOAuthResult oauthResult;
            var fb = new FacebookClient();
            if (!fb.TryParseOAuthCallbackUrl(e.Uri, out oauthResult))
            {
                return;
            }

            if (oauthResult.IsSuccess)
            {
                if (ProcessFbOathResult(oauthResult) == 1)
                {
                    Dispatcher.BeginInvoke(() => MessageBox.Show("Er is een fout opgetreden tijdens de authenticatie"));
                }
                gridFBLoggedIn.Visibility = Visibility.Visible;
                FaceBookLoginPage.Visibility = Visibility.Collapsed;
                Dispatcher.BeginInvoke(() => DataContext = App.ViewModel.UserPreference);
            }
            else
            {
                Dispatcher.BeginInvoke(() => MessageBox.Show("Er is een fout opgetreden tijdens de authenticatie"));
                FaceBookLoginPage.Navigate(new Uri(string.Format("https://www.facebook.com/logout.php?next={0}&access_token={1}", "https://www.facebook.com/connect/login_failure.html", App.ViewModel.UserPreference.AccessKey)));
                MainPivot_OnSelectionChanged(null, null);

            }
        }

        public int ProcessFbOathResult(FacebookOAuthResult oauthResult)
        {
            var resultCode = 0;
            var accessToken = oauthResult.AccessToken;
            App.ViewModel.UserPreference.AccessKey = accessToken;
            var fbS = new FacebookClient(accessToken);

            fbS.GetCompleted += (o, res) =>
                                    {
                                        if (res.Error != null)
                                        {
                                            resultCode = 1;
                                            return;
                                        }

                                        var result = (IDictionary<string, object>) res.GetResultData();
                                        App.ViewModel.UserPreference.FbUserId = (string) result["id"];
                                        App.ViewModel.UserPreference.Name = (string) result["name"];
                                        App.ViewModel.SaveSettings();
                                        Dispatcher.BeginInvoke(() =>
                                                                   {
                                                                       facebookImage.Source =
                                                                           App.ViewModel.UserPreference.UserImage;
                                                                       name.Text = App.ViewModel.UserPreference.Name;
                                                                   });
                                    };

            fbS.GetTaskAsync("me");
            return resultCode;
        }





        private void MainPivot_OnSelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (FaceBookLoginPage.Visibility == Visibility.Collapsed || mainPivot.SelectedItem != mainPivot.Items[1])
                return;

            FaceBookLoginPage.Navigate(
                App.ViewModel.FacebookLoginUrl("https://www.facebook.com/connect/login_success.html"));
        }

        private void UnlinkButtonClick(object sender, RoutedEventArgs e)
        {
            App.ViewModel.UnlinkFaceBook();
            var cookies = new CookieContainer().GetCookies(new Uri("https://login.facebook.com/login.php"));
           foreach (Cookie cookie in cookies)
           {
               cookie.Discard = true;
               cookie.Expired = true;
           }
            gridFBLoggedIn.Visibility = Visibility.Collapsed;
            FaceBookLoginPage.Visibility = Visibility.Visible;
            MainPivot_OnSelectionChanged(null,null);
        }


    }
}