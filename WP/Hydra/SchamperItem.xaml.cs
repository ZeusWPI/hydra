using System;
using System.Linq;
using System.Windows.Navigation;
using Microsoft.Phone.Controls;

namespace Hydra
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
            
            var item=App.ViewModel.SchamperItems.ElementAt(Convert.ToInt32(NavigationContext.QueryString["article"]));
            if (item != null)
            {
                author.Text = item.Author;
                title.Text = item.FullTitle;
                browser.NavigateToString(item.Content);
            }
        }
    }
}