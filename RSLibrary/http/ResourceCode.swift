enum ResourceCode{
    case SUCCESS
    case SERVER_ERROR
    case E8000  //WIFI NOT Connect
    case E9993  //USER ERROR
    case E9994  //HTTP Error
    case E9995  //Connection Timeout
    case E9996  //Socket Timeout
    case E9997  //UnKnow Host
    case E9998  //Parsing Error
    case E9999  //UnKnown Error
    
    
    func message() -> String{
        switch self{
            case .SUCCESS:
                return "성공"
            case .SERVER_ERROR:
                return "server_error"
            case .E8000:
                return "[8000]인터넷이 연결되어있지않습니다."
            case .E9993:
                return "server_error"
            case .E9994:
                return "[9994]데이터 통신에 실패하였습니다"
            case .E9995:
                return "[9995]서버 연결시간 초과"
            case .E9996:
                return "[9996]서버 연결시간 초과"
            case .E9997:
                return "[9997]서버를 찾을수 없습니다."
            case .E9998:
                return "[9998]데이터 변환시 오류발생"
            case .E9999:
                return "[9999]알수없는 오류"
        }
        
    }
}