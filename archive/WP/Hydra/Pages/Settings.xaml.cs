using System.Collections.Generic;
using System.Globalization;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;
using Facebook;
using Hydra.Data;
using Microsoft.Phone.Controls;

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
            App.ViewModel.LoadData(true);
            base.OnNavigatingFrom(e);
        }

        private void ToggleSwitch_OnChecked(object sender, RoutedEventArgs e)
        {
            toggleSwitch.Content = "Uit";
            
            App.ViewModel.UserPreference.IsFiltering = true;
            associations.IsEnabled = true;
        }

        private void ToggleSwitchUnChecked(object sender, RoutedEventArgs e)
        {
            toggleSwitch.Content = "Aan";
            App.ViewModel.UserPreference.IsFiltering = false;
            associations.IsEnabled = false;
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



        private async void FaceBookLoginPageNavigated(object sender, NavigationEventArgs e)
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
                await ProcessFbOathResult(oauthResult);
                gridFBLoggedIn.Visibility = Visibility.Visible;
                FaceBookLoginPage.Visibility = Visibility.Collapsed;
                Dispatcher.BeginInvoke(() => DataContext = App.ViewModel.UserPreference);
                FaceBookLoginPage.Visibility = Visibility.Collapsed;
                gridFBLoggedIn.Visibility = Visibility.Visible;
                LinkButton.Visibility = Visibility.Collapsed;
            }
            else
            {
                
                FaceBookLoginPage.Visibility=Visibility.Collapsed;
                gridFBLoggedIn.Visibility=Visibility.Collapsed;
                LinkButton.Visibility=Visibility.Visible;

            }
        }

        public async Task<bool> ProcessFbOathResult(FacebookOAuthResult oauthResult)
        {
            var resultProcess = false;
            var accessToken = oauthResult.AccessToken;
            App.ViewModel.UserPreference.AccessKey = accessToken;
            var fbS = new FacebookClient(accessToken);

            fbS.GetCompleted += (o, res) =>
                                    {
                                        if (res.Error != null)
                                        {
                                            Dispatcher.BeginInvoke(() =>
                                                                       {
                                                                           gridFBLoggedIn.Visibility =
                                                                               Visibility.Collapsed;
                                                                           FaceBookLoginPage.Visibility =
                                                                               Visibility.Collapsed;
                                                                           LinkButton.Visibility = Visibility.Visible;
                                                                       });
                                            
                                            return;
                                        }

                                        var result = (IDictionary<string, object>) res.GetResultData();
                                        App.ViewModel.UserPreference.FbUserId = (string) result["id"];
                                        App.ViewModel.UserPreference.Name = (string) result["name"];
                                        App.ViewModel.LoadData(true);
                                        App.ViewModel.SaveSettings();
                                        Dispatcher.BeginInvoke(() =>
                                                                   {
                                                                       facebookImage.Source =
                                                                           App.ViewModel.UserPreference.UserImage;
                                                                       name.Text = App.ViewModel.UserPreference.Name;
                                                                   });
                                        resultProcess = true;
                                    };

            await fbS.GetTaskAsync("me");
            return resultProcess;
        }






         private void LinkButtonClick(object sender, RoutedEventArgs e)
        {
            if (FaceBookLoginPage.Visibility == Visibility.Visible || mainPivot.SelectedItem != mainPivot.Items[1])
                return;

            FaceBookLoginPage.Navigate(App.ViewModel.FacebookLoginUrl("https://www.facebook.com/connect/login_success.html"));
            gridFBLoggedIn.Visibility = Visibility.Collapsed;
            FaceBookLoginPage.Visibility = Visibility.Visible;
            LinkButton.Visibility = Visibility.Collapsed;
        }

        private void UnlinkButtonClick(object sender, RoutedEventArgs e)
        {
            if(App.ViewModel.UserPreference.AccessKey == null)
                return;
            FaceBookLoginPage.ClearCookiesAsync();
            //App.ViewModel.UnlinkFaceBook();
            gridFBLoggedIn.Visibility = Visibility.Collapsed;
            FaceBookLoginPage.Visibility = Visibility.Collapsed;
            LinkButton.Visibility=Visibility.Visible;
        }


    }
}