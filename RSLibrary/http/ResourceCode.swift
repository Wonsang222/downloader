enum ResourceCode{
    case success
    case server_ERROR
    case e8000  //WIFI NOT Connect
    case e9993  //USER ERROR
    case e9994  //HTTP Error
    case e9995  //Connection Timeout
    case e9996  //Socket Timeout
    case e9997  //UnKnow Host
    case e9998  //Parsing Error
    case e9999  //UnKnown Error
    
    
    func message() -> String{
        switch self{
            case .success:
                return "성공"
            case .server_ERROR:
                return "server_error"
            case .e8000:
                return "인터넷이 연결되어있지않습니다.(0)"
            case .e9993:
                return "server_error"
            case .e9994:
                return "데이터 통신에 실패하였습니다.(4)"
            case .e9995:
                return "죄송합니다. 네트워크가 불안정하여 연결이 원활하지 않습니다. 잠시 후 다시 접속해주십시오.(5)"
            case .e9996:
                return "죄송합니다. 네트워크가 불안정하여 연결이 원활하지 않습니다. 잠시 후 다시 접속해주십시오.(6)"
            case .e9997:
                return "서버를 찾을수 없습니다.(7)"
            case .e9998:
                return "데이터 변환시 오류발생.(8)"
            case .e9999:
                return "서버와의 통신이 원활하지 않습니다.(9)"
        }
        
    }
}
