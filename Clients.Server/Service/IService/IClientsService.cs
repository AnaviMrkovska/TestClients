using Clients.Models;
namespace Clients.Server.Service.IService
{
    public interface IClientsService
    {
        public Task<IEnumerable<Clients.Models.Clients>> GetAllClients();
        public Task<Clients.Models.ClientsImport> InsertClientsFromXml(ClientsImport xml);
    }
}
