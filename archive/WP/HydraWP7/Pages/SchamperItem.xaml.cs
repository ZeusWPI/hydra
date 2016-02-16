using System;
using System.Linq;
using System.Windows.Navigation;
using Microsoft.Phone.Controls;

namespace HydraWP7.Pages
{
    public partial class SchamperItem : PhoneApplicationPage
    {
        public SchamperItem()
        {
            InitializeComponent();
        }

        // Load data for the ViewModel NewsItems
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {

            try
            {
                var item = App.ViewModel.SchamperItems.ElementAt(Convert.ToInt32(NavigationContext.QueryString["article"]));
                if (item == null) return;
                author.Text = item.Author;
                title.Text = item.FullTitle;
                var fullHtml = NewsItem.WrapHtml(item.Content, browser.ActualWidth);
                browser.NavigateToString(fullHtml);
            }
            catch (Exception)
            {
                NavigationService.Navigate(new Uri("/Pages/MainPage.xaml", UriKind.Relative));
            }
        }
    }
}