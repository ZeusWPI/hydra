using System;
using System.Linq;
using System.Windows.Navigation;
using Hydra.Data;
using Microsoft.Phone.Tasks;

namespace Hydra.Pages
{
    public partial class InfoItemBrowser
    {
        public InfoItemBrowser()
        {
            InitializeComponent();
        }

        // Load data for the info item
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {

            InfoItemsViewModel item = App.ViewModel.InfoItems.ElementAt(Convert.ToInt32(NavigationContext.QueryString["item"]));
            string itemtitle = null;
            Uri uri = null;
            int idx;
            try
            {
                idx = Convert.ToInt32(NavigationContext.QueryString["child"]);
            }catch(Exception)
            {
                idx = -1;
            }
            if (item != null && idx<0)
            {
                itemtitle = item.Title;
                uri=(new Uri(@item.Link,UriKind.Relative));

            }
            else if (item != null)
            {
                var child = item.Children.ElementAt(idx);
                itemtitle = child.Title;
                uri = (new Uri(@child.Link, UriKind.Relative));
            }
            else
            {
                //TODO:let's go back, shall we
            }
            title.Text = itemtitle;
            if (uri != null && !uri.ToString().StartsWith("http"))
                browser.Navigate(uri);
        }

        public static void BrowseToUrl(string url)
        {
            var task = new WebBrowserTask {Uri = new Uri(url,UriKind.Absolute)};
            task.Show();
        }
    }
}