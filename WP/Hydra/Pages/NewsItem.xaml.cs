using System;
using System.Linq;
using System.Windows.Navigation;
using Microsoft.Phone.Controls;

namespace Hydra.Pages
{
    public partial class NewsItem : PhoneApplicationPage
    {
        private const string Header = "<html><head><link rel='stylesheet' type='text/css' href='~/Resources/webview.css'></head><body>";
        public NewsItem()
        {
            InitializeComponent();
        }

        // Load data for the ViewModel NewsItems
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {

            var item = App.ViewModel.NewsItems.ElementAt(Convert.ToInt32(NavigationContext.QueryString["newsItem"]));
            if (item != null)
            {
                DataContext = item;
                browser.NavigateToString(Header+item.Content+"</body></html>");
            }
            else
            {
                //TODO:let's go back, shall we
            }
        }
    }
}